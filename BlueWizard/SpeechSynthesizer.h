#import <Foundation/Foundation.h>
@class Sampler;
@interface SpeechSynthesizer : NSObject

-(instancetype)initWithSampler:(Sampler *)sampler;
-(void)speak:(NSString *)speechID;
-(void)stop;

@end
