#import "TMS5220Processor.h"

@interface TMS5220Processor ()
@property (nonatomic, getter = isSpeaking) BOOL speaking;
@property (nonatomic) NSUInteger sampleRate;
@property (nonatomic) NSUInteger index;
@end

@implementation TMS5220Processor {
    tms5220_device *_tms5220;
}

-(instancetype)initWithSampleRate:(NSUInteger)sampleRate {
    if (self = [super init]) {
        self.sampleRate = sampleRate;

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

-(NSArray *)processLPC:(NSArray *)lpc {
    self.speaking = YES;
    NSMutableArray *samples = [NSMutableArray arrayWithCapacity:65536];
    
    while (self.isSpeaking) {
        [self speakFragment:lpc samples:samples];
    }

    return [samples copy];
}

-(void)fillBuffer:(NSMutableArray *)samples {
    unsigned int frames = _tms5220->m_fifo_count;
    int buffer[frames];
    _tms5220->process(buffer, frames);
    float scale = 1.0f / (1 << 15);
    for (int i = 0; i < frames; i++) {
        [samples addObject:[NSNumber numberWithFloat:buffer[i] * scale]];
    }
}

-(void)speakFragment:(NSArray *)speechData
             samples:(NSMutableArray *)samples {
    while (!_tms5220->m_ready_pin) {
        [self fillBuffer:samples];
    }
    
    int data = [[speechData objectAtIndex:self.index] intValue];
    
    _tms5220->wsq_w(1);
    _tms5220->data_w(data);
    _tms5220->wsq_w(0);
    
    if (self.index == [speechData count] - 1) {
        self.speaking = NO;
        self.index    = 0;
        return;
    }
    
    self.index += 1;
}

@end
