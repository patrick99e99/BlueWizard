#import <Foundation/Foundation.h>

@interface HexConverter : NSObject

+(NSArray *)process:(NSArray *)nibbles;
+(NSString *)stringFromData:(NSData *)data;
+(NSData *)dataFromString:(NSString *)string;

@end
