#import "HammingWindow.h"

@implementation HammingWindow

+(NSArray *)process:(NSArray *)buffer {
    NSUInteger numberOfSamples = [buffer count];
    NSMutableArray *newBuffer  = [NSMutableArray arrayWithCapacity:numberOfSamples];
    
    [buffer enumerateObjectsUsingBlock:^(NSNumber *sample, NSUInteger idx, BOOL *stop) {
        float window = 0.54f - 0.46f * cos(2 * M_PI * idx / (numberOfSamples - 1));
        [newBuffer addObject:[NSNumber numberWithFloat:[sample floatValue] * window]];
    }];

    return [newBuffer copy];
}

@end