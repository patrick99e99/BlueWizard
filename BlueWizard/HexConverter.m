#import "HexConverter.h"
#import "BitHelpers.h"
#import "BitPacker.h"

static char const *kHexChars = "0123456789ABCDEF";
static char const kTerminator = '\0';

@implementation HexConverter

+(NSArray *)process:(NSArray *)nibbles {
    NSMutableArray *hex = [NSMutableArray arrayWithCapacity:[nibbles count]];
    for (NSString *nibble in nibbles) {
        NSUInteger value = [BitHelpers valueForBinary:nibble];
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

+(NSString *)stringFromData:(NSData *)data {
    NSUInteger bytesCount = [data length];
    if (!bytesCount) return @"";
    char delimiter = [[BitPacker delimiter] characterAtIndex:0];
    const unsigned char *dataBuffer = [data bytes];
    char *chars = malloc(sizeof(char) * (bytesCount * 3 + 1));
    char *s = chars;
    for (int i = 0; i < bytesCount; ++i) {
        *s++ = kHexChars[((*dataBuffer & 0xF0) >> 4)];
        *s++ = kHexChars[(*dataBuffer & 0x0F)];
        if (i < bytesCount - 1) *s++ = delimiter;
        dataBuffer++;
    }
    *s = kTerminator;
    NSString *hexString = [NSString stringWithUTF8String:chars];
    free(chars);
    return hexString;
}

+(NSData *)dataFromString:(NSString *)string {
    const char *chars = [string UTF8String];
    NSUInteger length = [string length];
    NSMutableData *data = [NSMutableData dataWithCapacity:length / 2];
    char byteChars[3] = {kTerminator, kTerminator, kTerminator};
    unsigned long wholeByte;
    int i = 0;
    
    while (i < length) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }

    return data;
}

@end
