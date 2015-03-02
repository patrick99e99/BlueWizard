#import <Foundation/Foundation.h>

@class Sampler;
@interface Input : NSObject

-(instancetype)initWithSampler:(Sampler *)sampler URL:(NSURL *)url;

@end
