#import "CodingTable.h"

@implementation CodingTable

+(NSArray *)parameters {
    return @[
             kParameterGain,
             kParameterRepeat,
             kParameterPitch,
             kParameterK1,
             kParameterK2,
             kParameterK3,
             kParameterK4,
             kParameterK5,
             kParameterK6,
             kParameterK7,
             kParameterK8,
             kParameterK9,
             kParameterK10,
    ];
}
             
+(NSArray *)bits {
    return @[ @4, @1, @6, @5, @5, @4, @4, @4, @4, @4, @3, @3, @3 ];
}


@end
