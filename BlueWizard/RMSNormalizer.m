#import "RMSNormalizer.h"
#import "Reflector.h"
#import "UserSettings.h"
#import "CodingTable.h"
#import "FrameData.h"

@implementation RMSNormalizer

+(void)normalizeVoiced:(NSArray *)frameData {
    float max = 0.0f;
    for (FrameData *frame in frameData) {
        if (![frame.reflector isUnvoiced] && frame.reflector.rms > max) max = frame.reflector.rms;
    }

    if (max <= 0.0f) return;

    float scale = [CodingTable rms][[self maxRMSIndex]] / max;

    for (FrameData *frame in frameData) {
        if (![frame.reflector isUnvoiced]) frame.reflector.rms = frame.reflector.rms * scale;
    }
}

+(void)normalizeUnvoiced:(NSArray *)frameData {
    float max = 0.0f;
    for (FrameData *frame in frameData) {
        if ([frame.reflector isUnvoiced] && frame.reflector.rms > max) max = frame.reflector.rms;
    }
    
    if (max <= 0.0f) return;

    float scale = [CodingTable rms][[self maxUnvoicedRMSIndex]] / max;
    
    for (FrameData *frame in frameData) {
        if ([frame.reflector isUnvoiced]) frame.reflector.rms = frame.reflector.rms * scale;
    }
}

+(void)applyUnvoicedMultiplier:(NSArray *)frameData {
    float multiplier = [self unvoicedRMSMultiplier];
    for (FrameData *frame in frameData) {
        if ([frame.reflector isUnvoiced]) frame.reflector.rms *= multiplier;
    }
}

+(NSUInteger)maxRMSIndex {
    return [[[UserSettings sharedInstance] rmsLimit] unsignedIntegerValue];
}

+(NSUInteger)maxUnvoicedRMSIndex {
    return [[[UserSettings sharedInstance] unvoicedRMSLimit] unsignedIntegerValue];
}

+(float)unvoicedRMSMultiplier {
    return [[[UserSettings sharedInstance] unvoicedMultiplier] floatValue];
}

@end
