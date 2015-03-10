#import "SpeechSynthesizer.h"
#import "Buffer.h"
#import "UserSettings.h"
#import "tms5220.h"

@interface SpeechSynthesizer ()
@property (nonatomic, getter = isSpeaking) BOOL speaking;
@property (nonatomic) NSUInteger sampleRate;
@property (nonatomic) NSUInteger index;
@end

@implementation SpeechSynthesizer {
    tms5220_device *_tms5220;
}

+(Buffer *)processSpeechData:(NSArray *)lpc {
    return [[[self alloc] init] processSpeechData:lpc];
}

-(instancetype)init {
    if (self = [super init]) {
        NSUInteger sampleRate = [[[UserSettings sharedInstance] sampleRate] unsignedIntegerValue];
        _tms5220 = new tms5220_device();
        _tms5220->device_start();
        _tms5220->device_reset();
        _tms5220->set_frequency((int)sampleRate * 80);
    }
    return self;
}

-(void)dealloc {
    delete _tms5220;
}

-(Buffer *)processSpeechData:(NSArray *)lpc {
    self.speaking = YES;
    NSMutableArray *samples = [NSMutableArray arrayWithCapacity:65536];
    
    [self writeData:0x60];
    
    while (self.isSpeaking) {
        [self speakFragment:lpc samples:samples];
    }
    
    [self writeData:0xff];
    
    return [self bufferFor:samples];
}

-(Buffer *)bufferFor:(NSArray *)wrappedSamples {
    NSUInteger length = [wrappedSamples count];
    double *samples = (double *)malloc(sizeof(double) * length);
    for (int i = 0; i < length; i++) {
        samples[i] = [wrappedSamples[i] doubleValue];
    }
    
    Buffer *buffer = [[Buffer alloc] initWithSamples:samples size:length sampleRate:8000];

    free(samples);
    
    return buffer;
}

-(void)fillBuffer:(NSMutableArray *)samples {
    unsigned int frames = _tms5220->m_fifo_count;
    int buffer[frames];
    _tms5220->process(buffer, frames);
    float scale = 1.0f / (1 << 15);
    for (int i = 0; i < frames; i++) {
        [samples addObject:[NSNumber numberWithDouble:buffer[i] * scale]];
    }
}

-(void)writeData:(int)data {
    _tms5220->wsq_w(1);
    _tms5220->data_w(data);
    _tms5220->wsq_w(0);
}

-(void)speakFragment:(NSArray *)speechData
             samples:(NSMutableArray *)samples {
    while (!_tms5220->m_ready_pin) {
        [self fillBuffer:samples];
    }
    
    [self writeData:[[speechData objectAtIndex:self.index] intValue]];
    
    if (self.index == [speechData count] - 1) {
        self.speaking = NO;
        self.index    = 0;
        return;
    }
    
    self.index += 1;
}

@end
