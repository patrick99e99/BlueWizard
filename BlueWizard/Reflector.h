#import <Foundation/Foundation.h>

@interface Reflector : NSObject

@property (nonatomic) double rms;

+(instancetype)translateCoefficients:(double *)r numberOfSamples:(NSUInteger)numberOfSamples;
-(BOOL)isVoiced;
-(BOOL)isUnvoiced;
-(double *)ks;

@end
