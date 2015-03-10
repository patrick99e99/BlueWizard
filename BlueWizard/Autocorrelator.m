#import "Autocorrelator.h"
#import "Buffer.h"

@implementation Autocorrelator

+(void)getCoefficientsFor:(double *)coefficients forBuffer:(Buffer *)buffer {
    for (int i = 0; i <= 10; i++) {
        coefficients[i] = [self aForLag:i buffer:buffer];
    }
}

+(double)sumOfSquaresFor:(Buffer *)buffer {
    return [self aForLag:0 buffer:buffer];
}

+(double)aForLag:(NSUInteger)lag buffer:(Buffer *)buffer {
    NSUInteger samples = [buffer size] - lag;
    double sum = 0.0;

    for (int i = 0; i < samples; i++) {
        sum += buffer.samples[i] * buffer.samples[i + lag];
    }
    return sum;    
}

+(void)getNormalizedCoefficientsFor:(double *)coefficients
                          forBuffer:(Buffer *)buffer
                      minimumPeriod:(NSUInteger)minimumPeriod
                      maximumPeriod:(NSUInteger)maximumPeriod {
    
    for (NSUInteger lag = 0; lag <= maximumPeriod; lag++) {
        if (lag < minimumPeriod) {
            coefficients[lag] = 0.0;
            continue;
        }

        double sumOfSquaresBeginning = 0;
        double sumOfSquaresEnding = 0;

        double sum = 0.0;
        NSUInteger samples = [buffer size] - lag;
        for (int i = 0; i < samples; i++) {
            sum += buffer.samples[i] * buffer.samples[i + lag];
            sumOfSquaresBeginning += buffer.samples[i] * buffer.samples[i];
            sumOfSquaresEnding    += buffer.samples[i + lag] * buffer.samples[i + lag];
        }
        
        coefficients[lag] = sum / sqrt(sumOfSquaresBeginning * sumOfSquaresEnding);
    }
}

@end
