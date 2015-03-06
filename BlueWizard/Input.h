#import <Foundation/Foundation.h>

@class Buffer;
@interface Input : NSObject

-(instancetype)initWithURL:(NSURL *)URL;
-(Buffer *)buffer;

@end
