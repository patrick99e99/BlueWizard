#import "Reflector.h"
#import "UserSettings.h"
#import "CodingTable.h"

static NSUInteger const kNumberOfKParameters = 11;

@interface Reflector ()
@property (nonatomic, getter=shouldLimitRMS) BOOL limitRMS;
@end

@implementation Reflector {
    double *_ks[11];
}

+(instancetype)translateCoefficients:(double *)r
                     numberOfSamples:(NSUInteger)numberOfSamples {

    // Leroux Gueguen algorithm for finding K's

    double k[11] = {0};
    double b[11] = {0};
    double d[12] = {0};
    
    k[1] = -r[1] / r[0];
    d[1] = r[1];
    d[2] = r[0] + (k[1] * r[1]);
    
    int i = 2;
    while (i <= 10) {
        double y = r[i];
        b[1] = y;
    
        int j = 1;
        while (j <= i - 1) {
            b[j + 1] = d[j] + (k[j] * y);
            y = y + (k[j] * d[j]);
            d[j] = b[j];
            j += 1;
        }
    
        k[i] = -y / d[i];
        d[i + 1] = d[i] + (k[i] * y);
        d[i] = b[i];
        i += 1;
    }
    
    double rms = [self formattedRMS:d[11] numberOfSamples:numberOfSamples];
    return [[Reflector alloc] initWithKs:k rms:rms limitRMS:YES];
}

+(double)formattedRMS:(double)rms numberOfSamples:(NSUInteger)numberOfSamples {
    return sqrt(rms / numberOfSamples) * (1 << 15);
}

-(instancetype)init {
    if (self = [super init]) {
        for (int i = 0; i <= kNumberOfKParameters; i++) {
            _ks[i] = 0;
        }
    }
    return self;
}

-(instancetype)initWithKs:(double *)ks rms:(double)rms limitRMS:(BOOL)limitRMS {
    if (self = [super init]) {
        _rms      = rms;
        _limitRMS = limitRMS;
        memcpy(_ks, ks, sizeof(double) * kNumberOfKParameters);
    }
    return self;
}

-(double *)ks {
    return (double *)_ks;
}

-(double)rms {
    if (self.shouldLimitRMS && _rms >= [CodingTable rms][kStopFrameIndex - 1]) {
        return [CodingTable rms][kStopFrameIndex - 1];
    } else {
        return _rms;
    }
}

-(BOOL)isVoiced {
    return ![self isUnvoiced];
}

-(BOOL)isUnvoiced {
    return self.ks[1] >= [self unvoicedThreshold];
}

-(float)unvoicedThreshold {
    return [[[UserSettings sharedInstance] unvoicedThreshold] floatValue];
}

@end
