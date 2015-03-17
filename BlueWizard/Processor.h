#import <Foundation/Foundation.h>

@class Buffer;
@interface Processor : NSObject

+(instancetype)process:(Buffer *)buffer;
-(void)postNotificationsForFrames:(NSArray *)frames;

@end
