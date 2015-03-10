#import <Foundation/Foundation.h>
@class Buffer;
@interface PitchEstimator : NSObject

+(double)pitchForPeriod:(Buffer *)buffer;

@end
