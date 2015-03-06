#import "Reflector.h"

@interface Reflector ()
@property (nonatomic) float *ks;
@end

@implementation Reflector

+(instancetype)translateCoefficients:(float *)r numberOfSamples:(NSUInteger)numberOfSamples {

    // Leroux Guegen algorithm for finding K's

    float k[11] = {0};
    float b[11] = {0};
    float d[11] = {0};
    
    k[1] = -r[1] / r[0];
    d[1] = r[1];
    d[2] = r[0] + (k[1] * r[1]);
    
    int i = 2;
    while (i <= 10) {
        int y = r[i];
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
    
    NSUInteger rms = [self formattedRMS:d[10] numberOfSamples:numberOfSamples];
    return [[Reflector alloc] initWithKs:k rms:rms];
}

+(NSUInteger)formattedRMS:(float)rms numberOfSamples:(NSUInteger)numberOfSamples {
    return sqrt(rms / numberOfSamples) * (1 << 15);
}

-(instancetype)initWithKs:(float *)ks rms:(NSUInteger)rms {
    if (self = [super init]) {
        self.ks  = ks;
        self.rms = rms;
    }
    return self;
}

-(BOOL)isVoiced {
    return ![self isUnvoiced];
}

-(BOOL)isUnvoiced {
    return self.ks[1] >= [self unvoicedThreshold];
}

-(float)unvoicedThreshold {
    return 0.3f;
}

@end
