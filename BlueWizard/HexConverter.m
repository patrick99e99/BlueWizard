#import "HexConverter.h"
#import "BitHelpers.h"

@implementation HexConverter

+(NSArray *)process:(NSArray *)nibbles {
    NSMutableArray *hex = [NSMutableArray arrayWithCapacity:[nibbles count]];
    for (NSString *nibble in nibbles) {
        NSUInteger value = [BitHelpers valueForNibble:nibble];
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

@end