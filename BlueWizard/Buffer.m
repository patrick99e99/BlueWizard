#import "Buffer.h"
#import "Autocorrelator.h"

@interface Buffer ()
@property (nonatomic) float *samples;
@property (nonatomic) NSUInteger size;
@end

@implementation Buffer

-(instancetype)initWithSamples:(float *)samples
                          size:(NSUInteger)size {
    if (self = [super init]) {
        self.size = size;
        [self copySamples:samples];
    }
    return self;
}

-(float)energy {
    return [Autocorrelator sumOfSquaresFor:self];
}

-(void)copySamples:(float *)samples {
    self.samples = malloc(sizeof(float) * self.size);
    for (int i = 0; i < self.size; i++) {
        self.samples[i] = samples[i];
    }
}

-(void)dealloc {
    free(self.samples);
}

@end
