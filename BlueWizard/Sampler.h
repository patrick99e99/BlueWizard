#import <Foundation/Foundation.h>

@interface Sampler : NSObject

-(void)stream:(NSArray *)samples sampleRate:(NSUInteger)sampleRate;
-(void)stop;
-(NSArray *)samples;

@end
