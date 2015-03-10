#import <Foundation/Foundation.h>

@class Buffer;
@interface Processor : NSObject

+(instancetype)process:(Buffer *)buffer;

@end
