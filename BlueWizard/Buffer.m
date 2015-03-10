#import "Buffer.h"
#import "Autocorrelator.h"

@interface Buffer ()
@property (nonatomic) double *samples;
@property (nonatomic) NSUInteger size;
@property (nonatomic) NSUInteger sampleRate;
@end

@implementation Buffer

-(instancetype)initWithSize:(NSUInteger)size
                 sampleRate:(NSUInteger)sampleRate {
    if (self = [super init]) {
        self.size       = size;
        self.sampleRate = sampleRate;
        self.samples = malloc(sizeof(double) * self.size);
    }
    return self;
}

-(instancetype)initWithSamples:(double *)samples
                          size:(NSUInteger)size
                    sampleRate:(NSUInteger)sampleRate {
    if (self = [self initWithSize:size sampleRate:sampleRate]) {
        [self copySamples:samples];
    }
    return self;
}

-(void)copySamples:(double *)samples {
    for (int i = 0; i < self.size; i++) {
        self.samples[i] = samples[i];
    }
}

-(void)dealloc {
    free(self.samples);
}

-(double)energy {
    return [Autocorrelator sumOfSquaresFor:self];
}

@end
