#import "RMSNormalizer.h"
#import "Reflector.h"
#import "UserSettings.h"
#import "CodingTable.h"
#import "FrameData.h"

@implementation RMSNormalizer

+(void)normalize:(NSArray *)frameData {
    float max = 0.0f;
    for (FrameData *frame in frameData) {
        if (frame.reflector.rms > max) max = frame.reflector.rms;
    }

    if (max <= 0.0f) return;

    NSUInteger maxRMSIndex = [[[UserSettings sharedInstance] maxRMSIndex] unsignedIntegerValue];
    float scale = [CodingTable rms][maxRMSIndex] / max;

    for (FrameData *frame in frameData) {
        frame.reflector.rms = frame.reflector.rms * scale;
    }
}

@end
