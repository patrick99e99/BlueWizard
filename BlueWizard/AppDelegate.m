#import "AppDelegate.h"
#import "SpeechSynthesizer.h"
#import "Sampler.h"
#import "Input.h"
#import "Output.h"
#import "Processor.h"
#import "SpeechDataReader.h"
#import "SpeechSynthesizer.h"
#import "PlayheadView.h"
#import "NotificationNames.h"
#import "Buffer.h"
#import "BitPacker.h"
#import "Filterer.h"
#import "UserSettings.h"
#import "TimeMachine.h"
#import "HexConverter.h"

static NSString * const kExtensionBIN = @"bin";
static NSString * const kExtensionLPC = @"lpc";
static NSString * const kExtensionTXT = @"txt";
static NSString * const kExtensionAIF = @"aif";
static NSString * const kExtensionWAV = @"wav";

@interface AppDelegate ()

@property (nonatomic, strong) SpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) Sampler *sampler;
@property (nonatomic, strong) Input *input;
@property (nonatomic, strong) Processor *processor;
@property (nonatomic, strong) Buffer *buffer;
@property (nonatomic, strong) Buffer *bufferWIthEQ;
@property (nonatomic, strong) NSString *byteStream;
@property (nonatomic, strong) NSSavePanel *save;

@end

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playOriginalWasClicked:) name:playOriginalWasClicked object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopWasClicked:) name:stopOriginalWasClicked object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcessedWasClicked:) name:playProcessedWasClicked object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopWasClicked:) name:stopProcessedWasClicked object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bufferGenerated:) name:bufferGenerated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(byteStreamGenerated:) name:byteStreamGenerated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(byteStreamChanged:) name:byteStreamChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:settingsChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processInputWithEQ:) name:speedChanged object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameWasEdited:) name:frameWasEdited object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processInputWithEQ:) name:signalChanged object:nil];
}

-(void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.sampler stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(Sampler *)sampler {
    if (!_sampler) {
        _sampler = [[Sampler alloc] initWithDelegate:self];
    }
    return _sampler;
}

-(BOOL)hasInput {
    return !!self.input;
}

# pragma mark - MenuItems

-(IBAction)menuFileOpenAudioWasChosen:(id)sender {
    NSOpenPanel* dialog = [NSOpenPanel openPanel];
    [dialog setCanChooseFiles:YES];
    [dialog setCanChooseDirectories:YES];
    [dialog setAllowedFileTypes:@[kExtensionAIF, kExtensionWAV]];
    
    if ([dialog runModal] == NSModalResponseOK) {
        for (NSURL *URL in [dialog URLs]) {
            self.input = [[Input alloc] initWithURL:URL];
            [self processInputWithEQ:nil];
            [self processInputSignal];
        }
    }
}

-(IBAction)menuFileOpenLPCWasChosen:(id)sender {
    NSOpenPanel* dialog = [NSOpenPanel openPanel];
    [dialog setCanChooseFiles:YES];
    [dialog setCanChooseDirectories:YES];
    [dialog setAllowedFileTypes:@[kExtensionLPC, kExtensionBIN, kExtensionTXT]];
    if ([dialog runModal] == NSModalResponseOK) {
        for (NSURL *URL in [dialog URLs]) {
            NSData *data = [NSData dataWithContentsOfURL:URL];
            NSString *byteStream = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (!byteStream) byteStream = [HexConverter stringFromData:data];
            [self processFromByteStream:byteStream];
        }
    }
}

-(IBAction)menuFileSaveAudioWasChosen:(id)sender {
    NSSavePanel *dialog = [NSSavePanel savePanel];
    [dialog setExtensionHidden:NO];
    [dialog setAllowsOtherFileTypes:NO];
    [dialog setAllowedFileTypes:@[kExtensionAIF]];

    if ([dialog runModal] == NSModalResponseOK) {
        [Output createAIFFileFrom:self.buffer URL:[dialog URL]];
    }
}

-(IBAction)menuFileSaveLPCWasChosen:(id)sender {
    NSSavePanel *dialog = [NSSavePanel savePanel];
    self.save = dialog;

    [dialog setExtensionHidden:NO];
    [dialog setAllowsOtherFileTypes:NO];
    [dialog setAllowedFileTypes:@[kExtensionLPC, kExtensionBIN]];

    NSArray *buttonItems   = @[@"Text (*.lpc)", @"Binary (*.bin)"];
    NSView  *accessoryView = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 200, 32.0)];
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 60, 22)];
    [label setEditable:NO];
    [label setStringValue:@"Format:"];
    [label setBordered:NO];
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    
    NSPopUpButton *popupButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(50.0, 2, 140, 22.0) pullsDown:NO];
    [popupButton addItemsWithTitles:buttonItems];
    [popupButton setAction:@selector(selectFormat:)];
    [popupButton setTarget:self];
    [accessoryView addSubview:label];
    [accessoryView addSubview:popupButton];

    [dialog setAccessoryView:accessoryView];
    if ([dialog runModal] == NSModalResponseOK) {
        NSURL *url = [dialog URL];
        NSError *error;

        if ([[[url pathExtension] lowercaseString] isEqualToString:kExtensionBIN]) {
            NSString *withoutDelimiter = [[self.byteStream componentsSeparatedByString:[BitPacker delimiter]] componentsJoinedByString:@""];
            NSData *byteStreamData = [HexConverter dataFromString:withoutDelimiter];
            [byteStreamData writeToURL:url options:NSDataWritingAtomic error:&error];
        } else {
            [self.byteStream writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }

        if (error) NSLog(@"%@", [error description]);
    }
}

-(void)selectFormat:(id)sender {
    NSPopUpButton *button            = (NSPopUpButton *)sender;
    NSInteger selectedItemIndex      = [button indexOfSelectedItem];
    NSString *nameFieldString        = [self.save nameFieldStringValue];
    NSString *trimmedNameFieldString = [nameFieldString stringByDeletingPathExtension];
    NSString *extension = selectedItemIndex ? kExtensionBIN : kExtensionLPC;

    NSString *nameFieldStringWithExt = [NSString stringWithFormat:@"%@.%@", trimmedNameFieldString, extension];
    [self.save setNameFieldStringValue:nameFieldStringWithExt];
    [self.save setAllowedFileTypes:@[extension]];
}

-(void)processInputWithEQ:(NSNotification *)notification {
    [self.sampler stop];
    NSUInteger lowPassCutoff  = [[[self userSettings] lowPassCutoff] unsignedIntegerValue];
    NSUInteger highPassCutoff = [[[self userSettings] highPassCutoff] unsignedIntegerValue];
    float gain = [[[self userSettings] gain] floatValue];
    
    Buffer *buffer = [TimeMachine process:self.input.buffer];
    
    Filterer *filterer = [[Filterer alloc] initWithBuffer:buffer
                                        lowPassCutoffInHZ:lowPassCutoff
                                       highPassCutoffInHZ:highPassCutoff
                                                     gain:gain];

    self.bufferWIthEQ = [filterer process];
    [[NSNotificationCenter defaultCenter] postNotificationName:inputSignalReceived object:self.bufferWIthEQ];
}

-(void)playOriginalWasClicked:(NSNotification *)notification {
    NSArray *playheads = notification.object;
    [[playheads firstObject] setSampler:self.sampler];
    [[playheads lastObject] setSampler:nil];

    [self.sampler stream:self.bufferWIthEQ];
}

-(void)playProcessedWasClicked:(NSNotification *)notification {
    NSArray *playheads = notification.object;
    [[playheads firstObject] setSampler:nil];
    [[playheads lastObject] setSampler:self.sampler];

    [self.sampler stream:self.buffer];
}

-(void)settingsChanged:(NSNotification *)notification {
    if (!self.input) return;
    [self processInputSignal];
}

-(void)byteStreamChanged:(NSNotification *)notification {
    [self processFromByteStream:notification.object];
}

-(void)processFromByteStream:(NSString *)byteStream {
    self.byteStream = byteStream;
    NSArray *frames = [BitPacker unpack:byteStream];
    [self postNotificationForFrames:frames];
    self.input = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:inputSignalReceived object:nil];
}

-(void)frameWasEdited:(NSNotification *)notification {
    [self postNotificationForFrames:notification.object];
}

-(void)postNotificationForFrames:(NSArray *)frames {
    [self.sampler stop];
    self.processor = [[Processor alloc] init];
    [self.processor postNotificationsForFrames:frames];
}

-(void)processInputSignal {
    [self.sampler stop];
    Buffer *inputBuffer = self.bufferWIthEQ;
    Buffer *buffer = [[Buffer alloc] initWithSamples:inputBuffer.samples
                                                size:inputBuffer.size
                                          sampleRate:inputBuffer.sampleRate
                                               start:[[[self userSettings] startSample] unsignedIntegerValue]
                                                 end:[[[self userSettings] endSample] unsignedIntegerValue]];
    self.processor = [Processor process:buffer];
}

-(void)stopWasClicked:(NSNotification *)notification {
    [self.sampler stop];
}

-(void)bufferGenerated:(NSNotification *)notification {
    self.buffer = (Buffer *)notification.object;
}

-(void)byteStreamGenerated:(NSNotification *)notification {
    self.byteStream = (NSString *)notification.object;
}

# pragma mark - SamplerDelegate

-(void)didFinishStreaming:(Buffer *)buffer {
}

-(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

@end
