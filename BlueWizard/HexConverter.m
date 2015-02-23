#import "HexConverter.h"

@implementation HexConverter

+(NSArray *)process:(NSArray *)nibbles {
    NSMutableArray *hex = [NSMutableArray arrayWithCapacity:[nibbles count]];
    for (NSString *nibble in nibbles) {
        NSUInteger value = [self valueForNibble:nibble];
        [hex addObject:[NSString stringWithFormat:@"%x", (unsigned int)value]];
    }
    return [self inGroupsOfTwo:hex];
}

+(NSArray *)inGroupsOfTwo:(NSArray *)hex {
    NSMutableArray *grouped = [NSMutableArray arrayWithCapacity:[hex count] / 2];
    for (int i = 0, length = (int)[hex count]; i <= length - 2; i += 2) {
        [grouped addObject:[NSString stringWithFormat:@"%@%@", [hex objectAtIndex:i], [hex objectAtIndex:i + 1]]];
    }
    return [grouped copy];
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