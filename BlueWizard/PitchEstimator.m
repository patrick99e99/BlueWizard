#import "PitchEstimator.h"
#import "Buffer.h"
#import "UserSettings.h"
#import "Autocorrelator.h"

@interface PitchEstimator ()
@property (nonatomic, weak) Buffer *buffer;
@property (nonatomic, strong) NSNumber *bestPeriod;
@property (nonatomic) double *normalizedCoefficients;
@end

@implementation PitchEstimator {
}

+(double)pitchForPeriod:(Buffer *)buffer {
    double estimate = [[[self alloc] initWithBuffer:buffer] estimate];
//    NSLog(@"pitch: %f - %i", estimate, buffer.size);
    return estimate;
}

-(instancetype)initWithBuffer:(Buffer *)buffer {
    if (self = [super init]) {
        _buffer = buffer;
        _normalizedCoefficients = [self getNormalizedCoefficients];
    }
    return self;
}

-(void)dealloc {
    free(self.normalizedCoefficients);
}

-(BOOL)isOutOfRange {
    NSUInteger bestPeriod = [self.bestPeriod unsignedIntegerValue];
    return self.normalizedCoefficients[bestPeriod] < self.normalizedCoefficients[bestPeriod - 1] &&
           self.normalizedCoefficients[bestPeriod] < self.normalizedCoefficients[bestPeriod + 1];
}

-(double)interpolated {
    NSUInteger bestPeriod = [self.bestPeriod unsignedIntegerValue];
    double middle = self.normalizedCoefficients[bestPeriod];
    double left   = self.normalizedCoefficients[bestPeriod - 1];
    double right  = self.normalizedCoefficients[bestPeriod + 1];

    return bestPeriod + 0.5 * (right - left) / (2 * middle - left - right);
}

-(double)estimate {
    NSUInteger bestPeriod = [self.bestPeriod unsignedIntegerValue];
    NSUInteger maximumMultiple = bestPeriod / [self minimumPeriod];
    
    BOOL found = false;
    
    double estimate = [self interpolated];
    if (estimate != estimate) return 0.0;
        
    while (!found && maximumMultiple >= 1) {
        BOOL subMultiplesAreStrong = true;
        
        for (int i = 0; i < maximumMultiple; i++) {
            NSUInteger subMultiplePeriod = floor((i + 1) * estimate / maximumMultiple + 0.5);
                
            if (self.normalizedCoefficients[subMultiplePeriod] &&
                self.normalizedCoefficients[subMultiplePeriod] < [self subMultipleThreshold] * self.normalizedCoefficients[bestPeriod]) {
                subMultiplesAreStrong = false;
            }
        }
                    
        if (subMultiplesAreStrong) {
            estimate /= maximumMultiple;
            found = true;
        }
                
        maximumMultiple -= 1;
    }
                
    return estimate;
}

-(double *)getNormalizedCoefficients {
    NSUInteger minimumPeriod = [self minimumPeriod] - 1;
    NSUInteger maximumPeriod = [self maximumPeriod] + 1;
    
    double *normalizedCoefficients = malloc(sizeof(double) * maximumPeriod + 1);

    [Autocorrelator getNormalizedCoefficientsFor:normalizedCoefficients
                                       forBuffer:self.buffer
                                   minimumPeriod:minimumPeriod
                                   maximumPeriod:maximumPeriod];
    return normalizedCoefficients;
}

-(NSNumber *)bestPeriod {
    if (!_bestPeriod) {
        NSUInteger bestPeriod = [self minimumPeriod];
        NSUInteger startPeriod = bestPeriod + 1;
        NSUInteger maximumPeriod = [self maximumPeriod];

        for (NSUInteger period = startPeriod; period < maximumPeriod; period++) {
            if (self.normalizedCoefficients[period] > self.normalizedCoefficients[bestPeriod]) {
                bestPeriod = period;
            }
        }
        _bestPeriod = [NSNumber numberWithUnsignedInteger:bestPeriod];
    }
    return _bestPeriod;
}

-(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

-(NSUInteger)maximumPitchInHZ {
    return [[[self userSettings] maxPitchInHZ] unsignedIntegerValue];
}

-(NSUInteger)minimumPitchInHZ {
    return [[[self userSettings] minPitchInHZ] unsignedIntegerValue];
}

-(double)subMultipleThreshold {
    return [[[self userSettings] subMultipleThreshold] doubleValue];
}

-(NSUInteger)minimumPeriod {
    return floor([self.buffer sampleRate] / [self maximumPitchInHZ] - 1);
}
-(NSUInteger)maximumPeriod {
    return floor([self.buffer sampleRate] / [self minimumPitchInHZ] + 1);
}

@end
