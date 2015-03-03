#import <Foundation/Foundation.h>

@class Buffer;
@interface PreEmphasizer : NSObject

+(void)processBuffer:(Buffer *)buffer;

@end
