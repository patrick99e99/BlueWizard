#import <Foundation/Foundation.h>
@class Sampler;
@interface SpeechSynthesizer : NSObject

-(instancetype)initWithSampleRate:(NSUInteger)sampleRate sampler:(Sampler *)sampler;
-(NSUInteger)sampleRate;
-(void)speak:(NSString *)speechID;
-(void)stop;

@end
