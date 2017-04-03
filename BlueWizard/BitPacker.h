#import <Foundation/Foundation.h>

@interface BitPacker : NSObject

+(NSString *)delimiter;
+(NSString *)pack:(NSArray *)frameData;
+(NSArray *)unpack:(NSString *)packedData;

@end
