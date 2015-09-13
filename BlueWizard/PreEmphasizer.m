#import "PreEmphasizer.h"
#import "Buffer.h"
#import "UserSettings.h"

@implementation PreEmphasizer

+(void)processBuffer:(Buffer *)buffer {
    float preEnergy = [buffer energy];

    float alpha = [self alpha];
    float unmodifiedPreviousSample = buffer.samples[0];
    float tempSample;
    for (int i = 1; i < buffer.size; i++) {
        tempSample = buffer.samples[i];
        buffer.samples[i] -= (alpha * unmodifiedPreviousSample);
        unmodifiedPreviousSample = tempSample;
    }
    
    [self scaleBuffer:buffer preEnergy:preEnergy postEnergy:[buffer energy]];
}

+(float)alpha {
    return [[[UserSettings sharedInstance] preEmphasisAlpha] floatValue];
}

+(void)scaleBuffer:(Buffer *)buffer preEnergy:(double)preEnergy postEnergy:(double)postEnergy {
    float scale = sqrt(preEnergy / postEnergy);
    
    for (int i = 0; i < buffer.size; i++) {
        buffer.samples[i] *= scale;
    }
}

@end
