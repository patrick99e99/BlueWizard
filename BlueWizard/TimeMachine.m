#import "TimeMachine.h"
#import "Buffer.h"
#import "UserSettings.h"

@implementation TimeMachine

+(Buffer *)process:(Buffer *)buffer {
    UserSettings *userSettings = [UserSettings sharedInstance];
    
    float speedScale = [[userSettings speed] floatValue];
    NSUInteger size = ceil(buffer.size / speedScale);
    
    Buffer *processed = [[Buffer alloc] initWithSize:size sampleRate:buffer.sampleRate];
    
    float counter = 0.0f;
    float ratio = 1 * speedScale;
    for (int i = 0; i < size; i++) {
        NSUInteger index = floor(counter);
        processed.samples[i] = buffer.samples[index];
        counter += ratio;
    }

    [userSettings setStartSample:@0];
    [userSettings setEndSample:[NSNumber numberWithUnsignedInteger:size]];
    return processed;
}

@end
