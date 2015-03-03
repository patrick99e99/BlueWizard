#import <Foundation/Foundation.h>

@class Buffer;
@interface HammingWindow : NSObject

+(void)processBuffer:(Buffer *)buffer;

@end
