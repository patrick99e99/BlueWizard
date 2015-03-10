#import <Foundation/Foundation.h>

@class Buffer;
@interface Autocorrelator : NSObject

+(void)getCoefficientsFor:(double *)coefficients forBuffer:(Buffer *)buffer;

+(void)getNormalizedCoefficientsFor:(double *)coefficients
                          forBuffer:(Buffer *)buffer
                      minimumPeriod:(NSUInteger)minimumPeriod
                      maximumPeriod:(NSUInteger)maximumPeriod;

+(double)sumOfSquaresFor:(Buffer *)buffer;

@end

