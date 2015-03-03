#import <Foundation/Foundation.h>

@interface Buffer : NSObject

-(instancetype)initWithSamples:(float *)samples size:(NSUInteger)size;
-(float *)samples;
-(NSUInteger)size;
-(float)energy;

@end
