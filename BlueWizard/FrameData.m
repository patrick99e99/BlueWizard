#import "FrameData.h"
#import "Reflector.h"
#import "CodingTable.h"
#import "ClosestValueFinder.h"
#import "UserSettings.h"

@interface FrameData ()

@property (nonatomic, strong) Reflector *reflector;
@property (nonatomic) double pitch;
@property (nonatomic) BOOL repeat;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSDictionary *translatedParameters;

@end

@implementation FrameData

-(instancetype)initWithReflector:(Reflector *)reflector
                           pitch:(NSUInteger)pitch
                          repeat:(BOOL)repeat {
    if (self = [super init]) {
        self.reflector = reflector;
        self.pitch     = pitch;
        self.repeat    = repeat;
    }
    return self;
}

-(instancetype)init {
    if (self = [super init]) {
        self.reflector = [[Reflector alloc] init];
    }
    return self;
}

-(NSDictionary *)parameters {
    if (!_parameters) {
        _parameters = [self parametersWithTranslate:NO];
    }
    return _parameters;
}

-(NSDictionary *)translatedParameters {
    if (!_translatedParameters) {
        _translatedParameters = [self parametersWithTranslate:YES];
    }
    return _translatedParameters;
}

-(NSDictionary *)parametersWithTranslate:(BOOL)translate {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:kParameterKeys];
    
    parameters[kParameterGain] = [self parameterizedValueForRMS:self.reflector.rms translate:translate];
    if ([parameters[kParameterGain] doubleValue] > 0.0f) {
        
        parameters[kParameterRepeat] = [self parameterizedValueForRepeat:self.repeat];
        parameters[kParameterPitch]  = [self parameterizedValueForPitch:self.pitch translate:translate];
        
        if (![parameters[kParameterRepeat] boolValue]) {
            NSDictionary *ks = [self kParametersFrom:1 to:4 translate:translate];
            [parameters addEntriesFromDictionary:ks];
            
            if ([self.reflector isVoiced] && [parameters[kParameterPitch] unsignedIntegerValue]) {
                ks = [self kParametersFrom:5 to:10 translate:translate];
                [parameters addEntriesFromDictionary:ks];
            }
        }
    }
    
    return [parameters copy];
}

-(void)setParameter:(NSString *)parameter value:(NSNumber *)value {
    self.parameters = nil;
    self.translatedParameters = nil;

    if ([parameter isEqualToString:kParameterGain]) {
        NSUInteger index = [value unsignedIntegerValue];
        NSNumber *rms = [NSNumber numberWithFloat:[CodingTable rms][index]];
        self.reflector.rms = [rms floatValue];
    } else if ([parameter isEqualToString:kParameterRepeat]) {
        self.repeat = [value boolValue];
    } else if ([parameter isEqualToString:kParameterPitch]) {
        NSUInteger index = [value unsignedIntegerValue];
        NSNumber *pitch = [NSNumber numberWithFloat:[CodingTable pitch][index]];
        self.pitch = [pitch doubleValue];
    } else {
        NSUInteger bin = [[parameter substringFromIndex:1] integerValue];
        NSUInteger index = [value unsignedIntegerValue];
        NSNumber *k = [NSNumber numberWithFloat:[CodingTable kBinFor:bin][index]];
        self.reflector.ks[bin] = [k doubleValue];
    }
}

-(void)setParameter:(NSString *)parameter translatedValue:(NSNumber *)translatedValue {
    self.parameters = nil;
    self.translatedParameters = nil;
    
    if ([parameter isEqualToString:kParameterGain]) {
        self.reflector.rms = [translatedValue unsignedIntegerValue];
    } else if ([parameter isEqualToString:kParameterRepeat]) {
        self.repeat = [translatedValue boolValue];
    } else if ([parameter isEqualToString:kParameterPitch]) {
        self.pitch = [translatedValue unsignedIntegerValue];
    } else {
        NSUInteger bin = [[parameter substringFromIndex:1] integerValue];
        self.reflector.ks[bin] = [translatedValue doubleValue];
    }
}

-(NSNumber *)parameterizedValueForK:(double)k bin:(NSUInteger)bin translate:(BOOL)translate {
    NSUInteger index = [ClosestValueFinder indexFor:k
                                              table:[CodingTable kBinFor:bin]
                                               size:[CodingTable kSizeFor:bin]];

    if (translate) {
        return [NSNumber numberWithFloat:[CodingTable kBinFor:bin][index]];
    } else {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

-(NSNumber *)parameterizedValueForRMS:(double)rms translate:(BOOL)translate {
    NSUInteger index = [ClosestValueFinder indexFor:rms
                                              table:[CodingTable rms]
                                               size:[CodingTable rmsSize]];
    if (translate) {
        return [NSNumber numberWithFloat:[CodingTable rms][index]];
    } else {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

-(NSNumber *)parameterizedValueForPitch:(double)pitch translate:(BOOL)translate {
    if ([self.reflector isUnvoiced] || !self.pitch) return @0;

    NSUInteger offset = [[self userSettings] overridePitch] ?
        0 : [[[self userSettings] pitchOffset] unsignedIntegerValue];

    NSInteger index = [ClosestValueFinder indexFor:pitch
                                             table:[CodingTable pitch]
                                              size:[CodingTable pitchSize]];
    
    index += offset;
    
    if (index > 63) index = 63;
    if (index < 0)  index = 0;

    if (translate) {
        return [NSNumber numberWithFloat:[CodingTable pitch][index]];
    } else {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

-(NSNumber *)parameterizedValueForRepeat:(BOOL)repeat {
    return [NSNumber numberWithBool:repeat];
}

-(NSDictionary *)kParametersFrom:(NSUInteger)from
                              to:(NSUInteger)to
                       translate:(BOOL)translate {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:to - from];
    for (NSUInteger k = from; k <= to; k++) {
        NSString *key = [self parameterKeyForK:k];
        parameters[key] = [self parameterizedValueForK:self.reflector.ks[k] bin:k translate:translate];
    }
    return [parameters copy];
}

-(NSString *)parameterKeyForK:(NSUInteger)k {
    return [NSString stringWithFormat:@"k%lu", k];
}

-(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

@end
