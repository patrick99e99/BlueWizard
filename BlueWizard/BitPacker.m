#import "BitPacker.h"
#import "FrameDataBinaryEncoder.h"
#import "HexConverter.h"
#import "NibbleBitReverser.h"
#import "NibbleSwitcher.h"

@implementation BitPacker

+(NSString *)pack:(NSArray *)frameData {
    NSArray *binary = [FrameDataBinaryEncoder process:frameData];
    NSArray *hex    = [HexConverter process:binary];
    NSArray *reversed = [NibbleBitReverser process:hex];
    NSArray *switched = [NibbleSwitcher process:reversed];
    
    return [switched componentsJoinedByString:@","];
}

+(NSArray *)unpack:(NSString *)packedData {
    return @[];
}

@end