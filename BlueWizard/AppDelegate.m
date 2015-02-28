#import "AppDelegate.h"
#import "SpeechSynthesizer.h"
#import "Sampler.h"

@interface AppDelegate ()
@property (nonatomic, strong) SpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) Sampler *sampler;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.speechSynthesizer speak:@"blue_wizard"];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.speechSynthesizer stop];
}

-(SpeechSynthesizer *)speechSynthesizer {
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[SpeechSynthesizer alloc] initWithSampler:self.sampler];
    }
    return _speechSynthesizer;
}

-(Sampler *)sampler {
    if (!_sampler) {
        _sampler = [[Sampler alloc] init];
    }
    return _sampler;
}

@end
