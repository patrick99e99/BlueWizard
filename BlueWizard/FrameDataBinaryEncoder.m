#import "FrameDataBinaryEncoder.h"
#import "CodingTable.h"
#import "BitHelpers.h"

@implementation FrameDataBinaryEncoder

+(NSArray *)process:(NSArray *)parametersList {
    int *bits = [CodingTable bits];

    __block NSString *binary = @"";

    for (NSDictionary *parameters in parametersList) {
        
        [[CodingTable parameters] enumerateObjectsUsingBlock:^(NSString *parameter, NSUInteger idx, BOOL *stop) {
            NSNumber *value = [parameters objectForKey:parameter];
            if (value) {
                NSString *binaryValue = [BitHelpers valueToBinary:[value unsignedIntegerValue]
                                                             bits:bits[idx]];

                binary = [binary stringByAppendingString:binaryValue];
            } else { *stop = YES; }
        }];

    }
    return [self nibblesFrom:binary];
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

@end
