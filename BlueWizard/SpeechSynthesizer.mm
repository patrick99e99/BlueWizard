#import "SpeechSynthesizer.h"
#import "Buffer.h"
#import "UserSettings.h"
#import "tms5220.h"
#import "UserSettings.h"

#define SPEAK_EXTERNAL_COMMAND 0x60
#define RESET_COMMAND 0xFF
#define SAMPLES_PER_HALF_FRAME (200)
#define STATUS_TS_MASK 0x80
#define STATUS_BL_MASK 0x40
#define STATUS_BE_MASK 0x20

@interface SpeechSynthesizer ()
@property (nonatomic, getter = isSpeaking) BOOL speaking;
@property (nonatomic, getter = hasStartedTalking) BOOL startedTalking;
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

    self.startedTalking = NO;
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
    //_tms5220->wsq_w(1); // don't use these since we want to use the 5220 without worrying about timing the reads and writes
    _tms5220->data_w(data);
    //_tms5220->wsq_w(0);
}

-(int)readStatus {
    int tms_status;
    //_tms5220->rsq_w(1); // don't use these since we want to use the 5220 without worrying about timing the reads and writes
    tms_status = _tms5220->status_r();
    //_tms5220->rsq_w(0);
    NSLog(@"5220 DEBUG: Index: %lu, Status read: TS: %d, BL: %d, BE: %d, Started: %d", self.index, (tms_status&0x80)?1:0, (tms_status&0x40)?1:0, (tms_status&0x20)?1:0, self.hasStartedTalking);
    return tms_status;
}

-(void)speakFragment:(NSArray *)speechData
             samples:(NSMutableArray *)samples {
    // if the chip hasn't started talking yet, load the fifo with enough bytes to either unset the BL mask and get speech going, or enough that we've run out of input data.
    if (!(self.hasStartedTalking)) {
        while ( (self.index < ([speechData count] - 1)) && ([self readStatus]&STATUS_BL_MASK) ) {
            [self writeData:[[speechData objectAtIndex:self.index] intValue]];
            self.index += 1;
        }
    }
    
    [self fillBuffer:samples];

    // has the chip actually ever started talking yet?
    if ( (!(self.hasStartedTalking)) && ([self readStatus]&STATUS_TS_MASK) ) {
        self.startedTalking = YES;
    }
    
    // if we ran out of input data and never even started talking, give up, go home.
    if ( (!(self.hasStartedTalking)) && (self.index >= ([speechData count] - 1)) ) {
        NSLog(@"fatal tms5220 error: insufficient speech data (<9 bytes) to start synthesizing speech. Try adding a few silence frames to the end.");
        self.speaking = NO;
        self.index = 0;
        return;
    }
    
    if (self.hasStartedTalking) {
        // if we're talking, we need to keep the tms5220 fifo as full as we can.
        if (self.index < ([speechData count] - 1)) {
            // if we still have input data to send, try to fill the fifo until we run out of data or BL goes inactive
            while ( (self.index < ([speechData count] - 1)) && ([self readStatus]&STATUS_BL_MASK) ) {
                [self writeData:[[speechData objectAtIndex:self.index] intValue]];
                self.index += 1;
            }
        }
        else {
            // we're all out of input data!
            if (!([self readStatus]&STATUS_TS_MASK)) {
                // if talk status went inactive, shut everything down, we're done.
                self.speaking = NO;
                self.index = 0;
                return;
            }
            // if ts is still active and we're out of data, continue onward since we need to finish up speaking what's in the fifo.
        }
    }
        
    
    // if we exited speak external mode due to a stop frame in the middle of everything or a general desync, BAIL OUT! Otherwise we get gibberish speak or crashes or other non-fun stuff.
    if (_tms5220->m_DDIS == 0) {
        NSLog(@"Fatal tms5220 error, we've desynced and we're no longer in speak external mode. Bailing out.");
        self.speaking = NO;
        self.index    = 0;
    }
        
}

-(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

@end
