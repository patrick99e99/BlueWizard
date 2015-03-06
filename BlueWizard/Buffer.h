#import <Foundation/Foundation.h>

@interface Buffer : NSObject

-(instancetype)initWithSize:(NSUInteger)size
                 sampleRate:(NSUInteger)sampleRate;

-(instancetype)initWithSamples:(float *)samples
                          size:(NSUInteger)size
                    sampleRate:(NSUInteger)sampleRate;

-(float *)samples;
-(NSUInteger)size;
-(NSUInteger)sampleRate;
-(float)energy;

@end
