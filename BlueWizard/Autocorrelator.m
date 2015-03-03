#import "Autocorrelator.h"
#import "Buffer.h"

@implementation Autocorrelator

+(float *)getCoefficientsFor:(float *)coefficients forBuffer:(Buffer *)buffer {
    for (int i = 0; i <= 10; i++) {
        coefficients[i] = [self aForLag:i buffer:buffer];
    }
    return coefficients;
}

+(float)sumOfSquaresFor:(Buffer *)buffer {
    return [self aForLag:0 buffer:buffer];
}

+(float)aForLag:(NSUInteger)lag buffer:(Buffer *)buffer {
    NSUInteger samples = [buffer size] - lag;
    float sum = 0.0f;

    for (int i = 0; i < samples; i++) {
        sum += buffer.samples[i] * buffer.samples[i + lag];
    }
    
    return sum;
}

@end