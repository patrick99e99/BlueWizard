#import <Foundation/Foundation.h>

@interface Buffer : NSObject

-(instancetype)initWithSize:(NSUInteger)size
                 sampleRate:(NSUInteger)sampleRate;

-(instancetype)initWithSamples:(double *)samples
                          size:(NSUInteger)size
                    sampleRate:(NSUInteger)sampleRate;

-(double *)samples;
-(NSUInteger)size;
-(NSUInteger)sampleRate;
-(double)energy;

@end
