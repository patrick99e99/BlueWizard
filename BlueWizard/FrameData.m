#import "FrameData.h"
#import "Reflector.h"
#import "CodingTable.h"
#import "ClosestValueFinder.h"

@interface FrameData ()

@property (nonatomic, weak) Reflector *reflector;
@property (nonatomic) double pitch;
@property (nonatomic) BOOL repeat;
@property (nonatomic) BOOL translate;

@end

@implementation FrameData

-(instancetype)initWithReflector:(Reflector *)reflector
                           pitch:(NSUInteger)pitch
                          repeat:(BOOL)repeat
                       translate:(BOOL)translate {
    if (self = [super init]) {
        self.reflector = reflector;
        self.pitch     = pitch;
        self.repeat    = repeat;
        self.translate = translate;
    }
    return self;
}

-(NSDictionary *)parameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:13];
    
    parameters[kParameterGain] = [self parameterizedValueForRMS];
    if ([parameters[kParameterGain] doubleValue] > 0.0f) {

        parameters[kParameterRepeat] = [self parameterizedValueForRepeat];
        parameters[kParameterPitch]  = [self parameterizedValueForPitch];
        
        if (![parameters[kParameterRepeat] boolValue]) {
            parameters[kParameterK1] = [self parameterizedValueForK:1];
            parameters[kParameterK2] = [self parameterizedValueForK:2];
            parameters[kParameterK3] = [self parameterizedValueForK:3];
            parameters[kParameterK4] = [self parameterizedValueForK:4];
            
            if ([self.reflector isVoiced] && [parameters[kParameterPitch] unsignedIntegerValue]) {
                parameters[kParameterK5]  = [self parameterizedValueForK:5];
                parameters[kParameterK6]  = [self parameterizedValueForK:6];
                parameters[kParameterK7]  = [self parameterizedValueForK:7];
                parameters[kParameterK8]  = [self parameterizedValueForK:8];
                parameters[kParameterK9]  = [self parameterizedValueForK:9];
                parameters[kParameterK10] = [self parameterizedValueForK:10];
            }
        }
    }
    
    return [parameters copy];
}

-(NSNumber *)parameterizedValueForK:(NSUInteger)k {
    NSUInteger index = [ClosestValueFinder indexFor:self.reflector.ks[k]
                                              table:[CodingTable kBinFor:k]
                                               size:[CodingTable kSizeFor:k]];

    if (self.translate) {
        return [NSNumber numberWithFloat:[CodingTable kBinFor:k][index]];
    } else {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

-(NSNumber *)parameterizedValueForRMS {
    NSUInteger index = [ClosestValueFinder indexFor:self.reflector.rms
                                              table:[CodingTable rms]
                                               size:[CodingTable rmsSize]];
    if (self.translate) {
        return [NSNumber numberWithFloat:[CodingTable rms][index]];
    } else {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

-(NSNumber *)parameterizedValueForPitch {
    if ([self.reflector isUnvoiced]) return @0;

    NSUInteger index = [ClosestValueFinder indexFor:self.pitch
                                              table:[CodingTable pitch]
                                               size:[CodingTable pitchSize]];
    if (self.translate) {
        return [NSNumber numberWithFloat:[CodingTable rms][index]];
    } else {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

-(NSNumber *)parameterizedValueForRepeat {
    return [NSNumber numberWithBool:self.repeat];
}

@end
