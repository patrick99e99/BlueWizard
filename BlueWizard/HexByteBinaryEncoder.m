#import "HexByteBinaryEncoder.h"
#import "BitHelpers.h"

@implementation HexByteBinaryEncoder

+(NSArray *)process:(NSArray *)nibbles {
    NSMutableArray *binary = [NSMutableArray arrayWithCapacity:[nibbles count] * 2];
    for (NSString *nibble in nibbles) {
        NSString *leftByte  = [nibble substringToIndex:1];
        NSString *rightByte = [nibble substringFromIndex:1];

        if (!rightByte) {
            [binary addObject:@"0000"];
            [binary addObject:[self binaryForByte:leftByte]];
        } else {
            [binary addObject:[self binaryForByte:leftByte]];
            [binary addObject:[self binaryForByte:rightByte]];
        }
    }
    return binary;
}

+(NSString *)binaryForByte:(NSString *)byte {
    NSUInteger value = [BitHelpers byteToValue:byte];
    return [BitHelpers valueToBinary:value bits:4];
}

@end
