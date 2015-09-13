#import <Foundation/Foundation.h>

@interface RMSNormalizer : NSObject

+(void)normalizeVoiced:(NSArray *)frameData;
+(void)normalizeUnvoiced:(NSArray *)frameData;

@end
