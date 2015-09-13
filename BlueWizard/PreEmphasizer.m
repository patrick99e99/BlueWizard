#import "PreEmphasizer.h"
#import "Buffer.h"
#import "UserSettings.h"

@implementation PreEmphasizer

+(void)processBuffer:(Buffer *)buffer {
    double preEnergy = [buffer energy];
    
    double alpha = [self alpha];
    double unmodifiedPreviousSample = buffer.samples[0];
    double tempSample;
    for (int i = 1; i < buffer.size; i++) {
        tempSample = buffer.samples[i];
        buffer.samples[i] += (alpha * unmodifiedPreviousSample);
        unmodifiedPreviousSample = tempSample;
    }
    
    [self scaleBuffer:buffer preEnergy:preEnergy postEnergy:[buffer energy]];
}

+(float)alpha {
    return [[[UserSettings sharedInstance] preEmphasisAlpha] floatValue];
}

+(void)scaleBuffer:(Buffer *)buffer preEnergy:(double)preEnergy postEnergy:(double)postEnergy {
    double scale = sqrt(preEnergy / postEnergy);
    
    for (int i = 0; i < buffer.size; i++) {
        buffer.samples[i] *= scale;
    }
}

@end
