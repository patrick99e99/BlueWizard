#import <Foundation/Foundation.h>

@class Buffer;
@interface Autocorrelator : NSObject

+(float *)getCoefficientsFor:(float *)coefficients forBuffer:(Buffer *)buffer;
+(float)sumOfSquaresFor:(Buffer *)buffer;

@end

