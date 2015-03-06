#import <Foundation/Foundation.h>
@class Buffer;
@protocol SamplerDelegate;
@interface Sampler : NSObject

-(instancetype)initWithDelegate:(id<SamplerDelegate>)delegate;
-(void)stream:(Buffer *)buffer;
-(void)stop;

@end
