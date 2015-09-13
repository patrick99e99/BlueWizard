#import <Foundation/Foundation.h>

static NSString * const kParameterGain   = @"gain";
static NSString * const kParameterRepeat = @"repeat";
static NSString * const kParameterPitch  = @"pitch";
static NSString * const kParameterK1     = @"k1";
static NSString * const kParameterK2     = @"k2";
static NSString * const kParameterK3     = @"k3";
static NSString * const kParameterK4     = @"k4";
static NSString * const kParameterK5     = @"k5";
static NSString * const kParameterK6     = @"k6";
static NSString * const kParameterK7     = @"k7";
static NSString * const kParameterK8     = @"k8";
static NSString * const kParameterK9     = @"k9";
static NSString * const kParameterK10    = @"k10";
static NSUInteger const kParameterKeys   = 13;
static NSUInteger const kStopFrameIndex  = 15;

@interface CodingTable : NSObject

+(NSArray *)parameters;
+(int *)bits;
+(float *)pitch;
+(float *)rms;
+(float *)kBinFor:(NSUInteger)k;
+(NSUInteger)pitchSize;
+(NSUInteger)rmsSize;
+(NSUInteger)kSizeFor:(NSUInteger)k;

@end
