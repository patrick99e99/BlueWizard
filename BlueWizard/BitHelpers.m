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

+(NSUInteger)valueForBinary:(NSString *)binary {
    NSUInteger value = 0;
    const char *cString = [binary cStringUsingEncoding:NSUTF8StringEncoding];
    
    int length = (int)[binary length] - 1;
    for (int i = length; i >= 0; i--) {
        if (cString[i] == '1') value += (1 << abs(i - length));
    }
    return value;
}

+(NSUInteger)byteToValue:(NSString *)byte {
    int value;
    sscanf([byte UTF8String], "%x", &value);
    return value;
}

@end
