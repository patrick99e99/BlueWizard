#import "BitHelpers.h"

@implementation BitHelpers

+(NSString *)valueToBinary:(NSUInteger)value bits:(NSUInteger)bits {
    NSString *binary = @"";
    do {
        binary = [[NSString stringWithFormat: @"%lu", value & 1] stringByAppendingString:binary];
    } while (value >>= 1);
    
    return [self leftZeroPadded:binary bits:bits];
}

+(NSString *)leftZeroPadded:(NSString *)binary bits:(NSUInteger)bits {
    while ([binary length] < bits) {
        binary = [NSString stringWithFormat:@"0%@", binary];
    }
    return binary;
}

+(NSUInteger)valueForNibble:(NSString *)nibble {
    NSUInteger value = 0;
    const char *cString = [nibble cStringUsingEncoding:NSUTF8StringEncoding];
    
    for (int i = 3; i >= 0; i--) {
        if (cString[i] == '1') value += (1 << abs(i - 3));
    }
    return value;
}

@end
