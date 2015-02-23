#import "NibbleSwitcher.h"

@implementation NibbleSwitcher

+(NSArray *)process:(NSArray *)nibbles {
    NSMutableArray *switched = [NSMutableArray arrayWithCapacity:[nibbles count]];
    for (NSString *nibble in nibbles) {
        NSString *leftByte  = [nibble substringToIndex:1];
        NSString *rightByte = [nibble substringFromIndex:1];
        
        NSString *switchedNibble = [NSString stringWithFormat:@"%@%@", rightByte, leftByte];
        [switched addObject:switchedNibble];
    }
    
    return switched;
}

@end
