#import "FrameDataBinaryEncoder.h"
#import "CodingTable.h"

@implementation FrameDataBinaryEncoder

+(NSArray *)process:(NSArray *)frameData {
    NSArray *bits = [CodingTable bits];

    __block NSString *binary = @"";

    for (NSDictionary *frame in frameData) {
        
        [[CodingTable parameters] enumerateObjectsUsingBlock:^(NSString *parameter, NSUInteger idx, BOOL *stop) {
            NSNumber *value = [frame objectForKey:parameter];
            if (value) {
                NSString *binaryValue = [self valueToBinary:value bits:[bits objectAtIndex:idx]];
                binary = [binary stringByAppendingString:binaryValue];
            } else { *stop = YES; }
        }];

    }
    return [self nibblesFrom:binary];
}

+(NSString *)valueToBinary:(NSNumber *)value bits:(NSNumber *)bits {
    NSString *binary = @"";
    NSUInteger x = [value unsignedIntegerValue];
    do {
        binary = [[NSString stringWithFormat: @"%lu", x&1] stringByAppendingString:binary];
    } while (x >>= 1);
    
    return [self leftZeroPadded:binary bits:[bits unsignedIntegerValue]];
}

+(NSArray *)nibblesFrom:(NSString *)binary {
    NSMutableArray *nibbles = [NSMutableArray arrayWithCapacity:[binary length] / 4];
    while ([binary length] >= 4) {
        NSString *nibble = [binary substringToIndex:4];
        binary = [binary substringFromIndex:4];
        [nibbles addObject:nibble];
    }
    return [nibbles copy];
}

+(NSString *)leftZeroPadded:(NSString *)binary bits:(NSUInteger)bits {
    while ([binary length] < bits) {
        binary = [NSString stringWithFormat:@"0%@", binary];
    }
    return binary;
}

@end
