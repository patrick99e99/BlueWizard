#import <Foundation/Foundation.h>

@interface Buffer : NSObject <NSCopying>

-(instancetype)initWithSize:(NSUInteger)size
                 sampleRate:(NSUInteger)sampleRate;

-(instancetype)initWithSamples:(double *)samples
                          size:(NSUInteger)size
                    sampleRate:(NSUInteger)sampleRate;

-(instancetype)initWithSamples:(double *)samples
                          size:(NSUInteger)size
                    sampleRate:(NSUInteger)sampleRate
                         start:(NSUInteger)start
                           end:(NSUInteger)end;

-(double *)samples;
-(NSUInteger)size;
-(NSUInteger)sampleRate;
-(double)energy;

@end
