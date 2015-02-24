#import <Foundation/Foundation.h>

@interface BitHelpers : NSObject

+(NSString *)valueToBinary:(NSUInteger)value bits:(NSUInteger)bits;
+(NSUInteger)valueForBinary:(NSString *)binary;
+(NSUInteger)byteToValue:(NSString *)byte;

@end
