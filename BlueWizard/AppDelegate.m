#import "AppDelegate.h"
#import "SpeechSynthesizer.h"
#import "Sampler.h"
#import "Input.h"
#import "Output.h"
#import "TestSampleData.h"
#import "Processor.h"
#import "SpeechDataReader.h"
#import "SpeechSynthesizer.h"

@interface AppDelegate ()
@property (nonatomic, strong) SpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) Sampler *sampler;
@property (nonatomic, strong) Input *input;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSArray *speechData = [SpeechDataReader speechDataFromFile:@"blue_wizard"];
    Buffer *buffer = [SpeechSynthesizer processSpeechData:speechData];
    [self.sampler stream:buffer];
//    [self openFileBrowser];
//    
//    NSMutableArray *samples = [NSMutableArray array];
//    for (NSNumber *num in [TestSampleData samples]) {
//        float f = ((float)[num intValue]) / (1 << 15);
//        [samples addObject:[NSNumber numberWithFloat:f]];
//    }
//    [Output save:samples];
//    [self.sampler stream:[i samples] sampleRate:48000];
//    [self openFileBrowser];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.sampler stop];
}

-(Sampler *)sampler {
    if (!_sampler) {
        _sampler = [[Sampler alloc] initWithDelegate:self];
    }
    return _sampler;
}

-(void)openFileBrowser {
    NSOpenPanel* dialog = [NSOpenPanel openPanel];
    [dialog setCanChooseFiles:YES];
    [dialog setCanChooseDirectories:YES];
    
    if ([dialog runModal] == NSModalResponseOK) {
        for (NSURL* URL in [dialog URLs]) {
            self.input = [[Input alloc] initWithURL:URL];
            [Processor process:self.input.buffer];
        }
    }
}

# pragma mark - SamplerDelegate

-(void)didFinishStreaming:(Buffer *)buffer {
    [self.sampler stream:buffer];
}

@end
