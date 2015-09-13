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

@interface AppDelegate ()

@property (nonatomic, strong) SpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) Sampler *sampler;
@property (nonatomic, strong) Input *input;
@property (nonatomic, strong) Processor *processor;
@property (nonatomic, strong) Buffer *buffer;
@property (nonatomic, strong) Buffer *bufferWIthEQ;

@end

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    NSArray *speechData = [SpeechDataReader speechDataFromFile:@"blue_wizard"];
//    Buffer *buffer = [SpeechSynthesizer processSpeechData:speechData];
//    self.effectTest = [[EffectMachine alloc] initWithBuffer:buffer];
//    [self.effectTest process];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playOriginalWasClicked:) name:playOriginalWasClicked object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopWasClicked:) name:stopOriginalWasClicked object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcessedWasClicked:) name:playProcessedWasClicked object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopWasClicked:) name:stopProcessedWasClicked object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bufferGenerated:) name:bufferGenerated object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(byteStreamChanged:) name:byteStreamChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:settingsChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processInputWithEQ:) name:speedChanged object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameWasEdited:) name:frameWasEdited object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processInputWithEQ:) name:signalChanged object:nil];
}

-(void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.sampler stop];
}

-(Sampler *)sampler {
    if (!_sampler) {
        _sampler = [[Sampler alloc] initWithDelegate:self];
    }
    return _sampler;
}

# pragma mark - MenuItems

- (IBAction)MenuFileOpenWasChosen:(id)sender {
    NSOpenPanel* dialog = [NSOpenPanel openPanel];
    [dialog setCanChooseFiles:YES];
    [dialog setCanChooseDirectories:YES];
    
    if ([dialog runModal] == NSModalResponseOK) {
        for (NSURL* URL in [dialog URLs]) {
            self.input = [[Input alloc] initWithURL:URL];
            [self processInputWithEQ:nil];
            [self processInputSignal];
        }
    }
}

-(void)processInputWithEQ:(NSNotification *)notification {
    [self.sampler stop];
    NSUInteger lowPassCutoff  = [[[self userSettings] lowPassCutoff] unsignedIntegerValue];
    NSUInteger highPassCutoff = [[[self userSettings] highPassCutoff] unsignedIntegerValue];
    
    Buffer *buffer = [TimeMachine process:self.input.buffer];
    
    Filterer *filterer = [[Filterer alloc] initWithBuffer:buffer
                                        lowPassCutoffInHZ:lowPassCutoff
                                       highPassCutoffInHZ:highPassCutoff];

    self.bufferWIthEQ = [filterer process];
    [[NSNotificationCenter defaultCenter] postNotificationName:inputSignalReceived object:self.bufferWIthEQ];
}

-(void)playOriginalWasClicked:(NSNotification *)notification {
//    ((PlayheadView *)notification.object).sampler = self.sampler;
    [self.sampler stream:self.bufferWIthEQ];
}

-(void)playProcessedWasClicked:(NSNotification *)notification {
//    ((PlayheadView *)notification.object).sampler = self.sampler;
    [self.sampler stream:self.buffer];
}

-(void)settingsChanged:(NSNotification *)notification {
    if (!self.input) return;
    [self processInputSignal];
}

-(void)byteStreamChanged:(NSNotification *)notification {
    NSArray *frames = [BitPacker unpack:notification.object];
    [self postNotificationForFrames:frames];
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
    //    ((PlayheadView *)notification.object).sampler = self.sampler;
    [self.sampler stop];
    Buffer *inputBuffer = self.bufferWIthEQ;
    Buffer *buffer = [[Buffer alloc] initWithSamples:inputBuffer.samples size:inputBuffer.size sampleRate:inputBuffer.sampleRate];
    self.processor = [Processor process:buffer];
}

-(void)stopWasClicked:(NSNotification *)notification {
    [self.sampler stop];
}

-(void)bufferGenerated:(NSNotification *)notification {
    self.buffer = (Buffer *)notification.object;
}

# pragma mark - SamplerDelegate

-(void)didFinishStreaming:(Buffer *)buffer {
}

-(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

@end
