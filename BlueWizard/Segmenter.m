#import "Segmenter.h"
#import "Buffer.h"
#import "UserSettings.h"

@interface Segmenter ()
@property (nonatomic, weak) Buffer *buffer;
@property (nonatomic) NSUInteger size;
@property (nonatomic) NSUInteger windowWidth;
@end

@implementation Segmenter

-(instancetype)initWithBuffer:(Buffer *)buffer
                  windowWidth:(NSUInteger)windowWidth {
    if (self = [super init]) {
        float milliseconds = [[[UserSettings sharedInstance] frameRate] floatValue];
        self.size          = ceil(([buffer sampleRate] / 1000.0f) * milliseconds);
        self.buffer        = buffer;
        self.windowWidth   = windowWidth;
    }
    return self;
}

-(void)eachSegment:(void (^)(Buffer *, NSUInteger))block {
    NSUInteger length = [self numberOfSegments];
    for (int i = 0; i < length; i++) {
        double *samples = [self samplesForSegment:i];
        Buffer *buffer = [[Buffer alloc] initWithSamples:samples
                                                    size:[self sizeForWindow]
                                              sampleRate:[self.buffer sampleRate]];

        free(samples);
        block(buffer, i);
    }
}

-(double *)samplesForSegment:(NSUInteger)index {
    NSUInteger length = [self sizeForWindow];
    double *samples = malloc(sizeof(double) * length);
    for (int i = 0; i < length; i++) {
        NSUInteger sampleIndex = index * self.size + i;
        samples[i] = (sampleIndex < self.buffer.size) ? self.buffer.samples[sampleIndex] : 0.0;
    }
    return samples;
}

-(NSUInteger)sizeForWindow {
    return self.size * self.windowWidth;
}

-(NSUInteger)numberOfSegments {
    return ceil(self.buffer.size / (float)self.size);
}

@end
