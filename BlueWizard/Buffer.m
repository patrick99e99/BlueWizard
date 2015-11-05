#import "Buffer.h"
#import "Autocorrelator.h"

@interface Buffer ()
@property (nonatomic) double *samples;
@property (nonatomic) NSUInteger size;
@property (nonatomic) NSUInteger sampleRate;
@property (nonatomic) NSUInteger start;
@property (nonatomic) NSUInteger end;

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
                    sampleRate:(NSUInteger)sampleRate
                         start:(NSUInteger)start
                           end:(NSUInteger)end {
    if (self = [self initWithSize:end - start sampleRate:sampleRate]) {
        self.start = start;
        self.end   = end;
        [self copySamples:samples];
    }
    return self;
}

-(instancetype)initWithSamples:(double *)samples
                          size:(NSUInteger)size
                    sampleRate:(NSUInteger)sampleRate {
    return [self initWithSamples:samples size:size sampleRate:sampleRate start:0 end:size];
}

-(void)copySamples:(double *)samples {
    for (int i = 0; i < self.size; i++) {
        if (i >= self.start) {
            NSUInteger index = i - self.start;
            self.samples[index] = samples[i];
        }
    }
}

-(void)dealloc {
    free(self.samples);
}

-(double)energy {
    return [Autocorrelator sumOfSquaresFor:self];
}

# pragma mark - NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithSamples:self->_samples
                                            size:self->_size
                                      sampleRate:self->_sampleRate];
}

@end
