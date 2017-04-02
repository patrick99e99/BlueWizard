#import <Foundation/Foundation.h>

@class Buffer;
@interface Output : NSObject

+(void)createAIFFileFrom:(Buffer *)buffer URL:(NSURL *)URL;

@end
