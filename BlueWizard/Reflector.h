#import <Foundation/Foundation.h>

@interface Reflector : NSObject

@property (nonatomic) NSUInteger rms;

+(instancetype)translateCoefficients:(float *)r numberOfSamples:(NSUInteger)numberOfSamples;
-(BOOL)isVoiced;
-(BOOL)isUnvoiced;
-(float *)ks;

@end
