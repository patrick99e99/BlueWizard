#import "SpeechSynthesizer.h"
#import "Buffer.h"
#import "UserSettings.h"
#import "tms5220.h"
#import "UserSettings.h"

static int const SPEAK_EXTERNAL_COMMAND = 0x60;
static int const RESET_COMMAND = 0xFF;
static int const SAMPLES_PER_HALF_FRAME = 200;
static int const STATUS_TS_MASK = 0x80;
static int const STATUS_BL_MASK = 0x40;
static int const STATUS_BE_MASK = 0x20;

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
    NSAssert(!self.speaking, @"already speaking!");

    self.speaking = YES;
    NSMutableArray *samples = [NSMutableArray arrayWithCapacity:65536];
    
    _tms5220->set_use_raw_excitation_filter([[self userSettings] excitationFilterOnly]);
    
    [self writeData:SPEAK_EXTERNAL_COMMAND];
    
    while (self.isSpeaking) {
        [self speakFragment:lpc samples:samples];
    }
    
    [self writeData:RESET_COMMAND];
    
    return [self bufferFor:samples];
}

-(Buffer *)bufferFor:(NSArray *)wrappedSamples {
    NSUInteger length = [wrappedSamples count];
    double *samples = (double *)malloc(sizeof(double) * length + 1);
    for (int i = 0; i < length; i++) {
        samples[i] = [wrappedSamples[i] doubleValue];
    }
    samples[length] = 0.0;
    
    Buffer *buffer = [[Buffer alloc] initWithSamples:samples size:length + 1 sampleRate:8000];

    free(samples);
    
    return buffer;
}

-(void)fillBuffer:(NSMutableArray *)samples {
    short int buffer[SAMPLES_PER_HALF_FRAME];
    _tms5220->process(buffer, SAMPLES_PER_HALF_FRAME);
    float scale = 1.0f / (1 << 15);
    for (int i = 0; i < SAMPLES_PER_HALF_FRAME; i++) {
        [samples addObject:[NSNumber numberWithDouble:buffer[i] * scale]];
    }
}

-(void)writeData:(int)data {
    _tms5220->data_w(data);
}

-(int)readStatus {
    int tms_status = _tms5220->status_r();
    NSLog(@"5220 DEBUG: Index: %lu, Status read: TS: %d, BL: %d, BE: %d", self.index, (tms_status&0x80)?1:0, (tms_status&0x40)?1:0, (tms_status&0x20)?1:0);
    return tms_status;
}

-(BOOL)chipHasNotStartedTalkingYetAndSentNoData {
    return !([self readStatus] & STATUS_TS_MASK) && !self.index;
}

-(void)speakFragment:(NSArray *)speechData
             samples:(NSMutableArray *)samples {
    // If the chip hasn't started talking yet, and we have yet to send any data...
    if ( [self chipHasNotStartedTalkingYetAndSentNoData] ) {
        // Load the fifo with enough bytes to either unset the BL mask and get speech going, or enough that we've run out of input data.
        while ( (self.index <= ([speechData count] - 1)) && ([self readStatus] & STATUS_BL_MASK) ) {
            [self writeData:[[speechData objectAtIndex:self.index] intValue]];
            self.index += 1;
        }
        // If we ran out of input data and never even filled the fifo, bail out.
        if ( (self.index > ([speechData count] - 1)) && ([self readStatus] & STATUS_BL_MASK) ) {
            NSLog(@"TMS5220 error: insufficient speech data (<9 bytes) to start synthesizing speech");
            self.speaking = NO;
            self.index = 0;
            return;
        }
    }
    else {
        // We're either talking or have finished talking. First check if there's any data left to send...
        if (self.index <= ([speechData count] - 1)) {
            // We still have input data to send, so try to fill the fifo until we run out of data or BL goes inactive
            while ( (self.index <= ([speechData count] - 1)) && ([self readStatus] & STATUS_BL_MASK) ) {
                [self writeData:[[speechData objectAtIndex:self.index] intValue]];
                self.index += 1;
            }
        }
        // Now, no matter if we have data left to send or not, check the talk status line. if it is inactive, finish up, since we either finished speech or desynced.
        if (!([self readStatus] & STATUS_TS_MASK)) {
           // If talk status went inactive, shut everything down, we're done.
           self.speaking = NO;
           self.index = 0;
           return;
        }
    }

    [self fillBuffer:samples]; // Generate some samples

}

-(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

@end
