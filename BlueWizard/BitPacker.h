#import <Foundation/Foundation.h>

@interface BitPacker : NSObject

+(NSString *)pack:(NSArray *)frameData;
+(NSArray *)unpack:(NSString *)packedData;

@end