#import "RMSNormalizer.h"
#import "Reflector.h"
#import "UserSettings.h"
#import "CodingTable.h"

@implementation RMSNormalizer

+(void)normalize:(NSArray *)reflectors {
    float max = 0.0f;
    for (Reflector *reflector in reflectors) {
        if (reflector.rms > max) max = reflector.rms;
    }

    if (max <= 0.0f) return;

    NSUInteger maxRMSIndex = [[[UserSettings sharedInstance] maxRMSIndex] unsignedIntegerValue];
    float scale = [CodingTable rms][maxRMSIndex] / max;

    for (Reflector *reflector in reflectors) {
        reflector.rms = reflector.rms * scale;
    }
}

@end
