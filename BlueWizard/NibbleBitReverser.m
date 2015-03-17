#import "NibbleBitReverser.h"
#import "BitHelpers.h"

@implementation NibbleBitReverser

+(NSArray *)process:(NSArray *)nibbles {
    NSMutableArray *reversed = [NSMutableArray arrayWithCapacity:[nibbles count]];
    for (NSString *nibble in nibbles) {
        NSString *leftByte  = [nibble substringToIndex:1];
        NSString *rightByte = [nibble length] == 1 ? @"0" : [nibble substringFromIndex:1];
        
        NSString *reversedNibble = [NSString stringWithFormat:@"%x%x",
                                    (int)[self reversedValueFor:leftByte],
                                    (int)[self reversedValueFor:rightByte]];
        [reversed addObject:reversedNibble];
    }
    
    return reversed;
}

+(NSUInteger)reversedValueFor:(NSString *)byte {
    NSUInteger value = [BitHelpers byteToValue:byte];
    NSString *binary = [BitHelpers valueToBinary:value bits:4];
    NSString *reversed = @"";
    const char *cString = [binary cStringUsingEncoding:NSUTF8StringEncoding];
    
    for (int i = 3; i >= 0; i--) {
        reversed = [reversed stringByAppendingString:[NSString stringWithFormat:@"%c", cString[i]]];
    }
    
    return [BitHelpers valueForBinary:reversed];
}

@end