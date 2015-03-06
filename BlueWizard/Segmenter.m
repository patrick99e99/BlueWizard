#import "Segmenter.h"
#import "Buffer.h"
#import "UserSettings.h"

@interface Segmenter ()
@property (nonatomic, weak) Buffer *buffer;
@property (nonatomic) NSUInteger size;
@property (nonatomic) NSUInteger windowWidth;
@property (nonatomic) NSUInteger counter;
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
    self.counter = 0;
    
    for (int i = 0; i < length; i++) {
        float *samples = [self samplesForSegment:i];
        Buffer *buffer = [[Buffer alloc] initWithSamples:samples
                                                    size:[self sizeForWindow]
                                              sampleRate:[self.buffer sampleRate]];
        free(samples);
        block(buffer, i);
    }
}

-(float *)samplesForSegment:(NSUInteger)index {
    NSUInteger length = [self sizeForWindow];
    float *samples = malloc(sizeof(float) * length);
    for (int i = 0; i < length; i++) {
        if (self.counter < self.buffer.size) {
            samples[i] = self.buffer.samples[index];
        } else {
            samples[i] = 0;
        }
        self.counter += 1;
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
