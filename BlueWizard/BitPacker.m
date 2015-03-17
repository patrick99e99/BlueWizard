#import "BitPacker.h"
#import "FrameDataBinaryEncoder.h"
#import "HexConverter.h"
#import "NibbleBitReverser.h"
#import "NibbleSwitcher.h"
#import "HexByteBinaryEncoder.h"
#import "CodingTable.h"
#import "BitHelpers.h"
#import "FrameData.h"

static NSString * const kFrameDataParametersMethodName = @"parameters";

@implementation BitPacker

+(NSString *)pack:(NSArray *)frameData {
    NSArray *parametersList = [frameData valueForKey:kFrameDataParametersMethodName];
    NSArray *binary   = [FrameDataBinaryEncoder process:parametersList];
    NSArray *hex      = [HexConverter process:binary];
    NSArray *reversed = [NibbleBitReverser process:hex];
    NSArray *switched = [NibbleSwitcher process:reversed];
    
    return [switched componentsJoinedByString:@","];
}

+(NSArray *)unpack:(NSString *)packedData {
    NSArray *bytes    = [packedData componentsSeparatedByString:@","];
    NSArray *switched = [NibbleSwitcher process:bytes];
    NSArray *reversed = [NibbleBitReverser process:switched];
    NSString *binary  = [[HexByteBinaryEncoder process:reversed] componentsJoinedByString:@""];
    return [self frameDataFor:binary];
}

+(NSArray *)frameDataFor:(NSString *)binary {
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:[binary length]];
    
    int *bits = [CodingTable bits];
    __block NSString *binaryString = binary;
    while (binaryString) {
        NSMutableArray *frameKeys = [NSMutableArray arrayWithCapacity:kParameterKeys];
        FrameData *frame = [[FrameData alloc] init];
        [[CodingTable parameters] enumerateObjectsUsingBlock:^(NSString *parameter, NSUInteger idx, BOOL *stop) {
            NSUInteger parameterBits = bits[idx];
            NSUInteger length        = [binaryString length];
            NSUInteger shift         = length < parameterBits ? (parameterBits - length) : 0;
            NSUInteger value         = [BitHelpers valueForBinary:[binaryString substringToIndex:parameterBits - shift]] << shift;
            binaryString = length >= parameterBits ? [binaryString substringFromIndex:parameterBits] : nil;
            
            [frame setParameter:parameter value:[NSNumber numberWithUnsignedInteger:value]];
            [frameKeys addObject:parameter];
            NSDictionary *parameters = [frame parameters];
            if ([self parametersHaveNoGain:parameters] ||
                [self parametersAreUnvoicedAndComplete:parameters frameKeys:frameKeys] ||
                [self parametersAreRepeatedAndComplete:parameters frameKeys:frameKeys]) *stop = YES;
        }];

        [frames addObject:frame];
    }
    return frames;
}

+(BOOL)parametersHaveNoGain:(NSDictionary *)parameters {
    return ![[parameters objectForKey:kParameterGain] unsignedIntegerValue];
}

+(BOOL)parametersAreUnvoicedAndComplete:(NSDictionary *)parameters frameKeys:(NSArray *)frameKeys {
    return ![[parameters objectForKey:kParameterPitch] unsignedIntegerValue] &&
            [self frameHasExactKeys:[self unvoicedKeys] frameKeys:frameKeys];
}

+(BOOL)parametersAreRepeatedAndComplete:(NSDictionary *)parameters frameKeys:(NSArray *)frameKeys  {
    return [[parameters objectForKey:kParameterRepeat] unsignedIntegerValue] == 1 &&
            [self frameHasExactKeys:[self repeatKeys] frameKeys:frameKeys];
}

+(BOOL)frameHasExactKeys:(NSArray *)keys frameKeys:(NSArray *)frameKeys {
    if ([keys count] != [frameKeys count]) return NO;
    
    for (NSString *key in frameKeys) {
        if (![keys containsObject:key]) return NO;
    }
    return YES;
}

+(NSArray *)unvoicedKeys {
    static NSArray *_unvoicedKeys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _unvoicedKeys = @[kParameterGain,
                          kParameterRepeat,
                          kParameterPitch,
                          kParameterK1,
                          kParameterK2,
                          kParameterK3,
                          kParameterK4];
    });
    return _unvoicedKeys;
}

+(NSArray *)repeatKeys {
    static NSArray *_repeatKeys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _repeatKeys = @[kParameterGain,
                        kParameterRepeat,
                        kParameterPitch];
    });
    return _repeatKeys;
}

@end
