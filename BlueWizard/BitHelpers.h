#import <Foundation/Foundation.h>

@interface BitHelpers : NSObject

+(NSString *)valueToBinary:(NSUInteger)value bits:(NSUInteger)bits;
+(NSUInteger)valueForNibble:(NSString *)nibble;

@end
