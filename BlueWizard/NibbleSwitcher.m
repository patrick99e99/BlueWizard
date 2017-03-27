#import "NibbleSwitcher.h"

@implementation NibbleSwitcher

+(NSArray *)process:(NSArray *)nibbles {
    NSMutableArray *switched = [NSMutableArray arrayWithCapacity:[nibbles count]];
    for (NSString *nibble in nibbles) {
        NSUInteger offset = [nibble length] == 4 ? 2 : 0;
        NSString *leftByte  = [nibble substringToIndex:1 + offset];
        NSString *rightByte = [nibble substringFromIndex:1 + offset];
        
        NSString *switchedNibble = [NSString stringWithFormat:@"%@%@", rightByte, leftByte];
        [switched addObject:switchedNibble];
    }
    
    return switched;
}

@end
