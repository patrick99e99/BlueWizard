#import "Sampler.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioHelpers.h"
#import "Buffer.h"
#import "SamplerDelegate.h"

@interface Sampler ()

@property (nonatomic) NSUInteger sampleRate;
@property (nonatomic, weak) id<SamplerDelegate>delegate;
@property (nonatomic) BOOL streaming;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger bufferSize;

-(void)didFinishStreaming:(Buffer *)buffer;

@end

static NSUInteger const kSampleRate = 48000;

typedef struct SamplerPlayer {
    AudioUnit outputUnit;
    NSUInteger counter;
    NSUInteger index;
    float ratio;
    __unsafe_unretained Buffer *buffer;
    __unsafe_unretained Sampler *sampler;
} SamplerPlayer;

OSStatus CallbackRenderProc(void *inRefCon,
                            AudioUnitRenderActionFlags *ioActionFlags,
                            const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber,
                            UInt32 inNumberFrames,
                            AudioBufferList * ioData);
void CreateAndConnectOutputUnit (SamplerPlayer *player);

OSStatus CallbackRenderProc(void *inRefCon,
                            AudioUnitRenderActionFlags *ioActionFlags,
                            const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber,
                            UInt32 inNumberFrames,
                            AudioBufferList * ioData) {
    struct SamplerPlayer *player = (struct SamplerPlayer *)inRefCon;

    if (!player->sampler.streaming) return noErr;

    for (int i = 0; i < inNumberFrames; i++) {
        NSUInteger index = floor(player->counter / player->ratio);
        player->sampler.index = index;

        SInt16 sample = player->buffer.samples[index] * (1 << 15);
        ((SInt16 *)ioData->mBuffers[0].mData)[i] = sample;

        if (index == player->buffer.size - 1) {
            [player->sampler performSelectorOnMainThread:@selector(didFinishStreaming:)
                                              withObject:player->buffer
                                           waitUntilDone:NO];
            break;
        } else {
            player->counter += 1;
        }
    }
    
    return noErr;
}

@implementation Sampler {
    SamplerPlayer player;
}

-(instancetype)initWithDelegate:(id<SamplerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

-(void)stream:(Buffer *)buffer {
    if (!buffer) return;
    
    [self stop];
    self.streaming = YES;
    
    struct SamplerPlayer initialized = {0};
    player = initialized;
    player.ratio   = (float)kSampleRate / buffer.sampleRate;
    player.buffer  = buffer;
    player.sampler = self;
    self.bufferSize = buffer.size;

    [self createAndConnectOutputUnit];

    CheckError(AudioOutputUnitStart(player.outputUnit), "Couldn't start output unit");
}

-(void)createAndConnectOutputUnit {
    AudioComponentDescription outputcd = {0};
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_DefaultOutput;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponent comp = AudioComponentFindNext (NULL, &outputcd);
    if (comp == NULL) {
        printf ("can't get output unit");
        exit (-1);
    }

    AudioComponentInstanceNew(comp, &player.outputUnit);
    
    // register render callback
    AURenderCallbackStruct input;
    input.inputProc = CallbackRenderProc;
    input.inputProcRefCon = &player;

    CheckError(AudioUnitSetProperty(player.outputUnit,
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Input,
                                    0,
                                    &input,
                                    sizeof(input)),
               "AudioUnitSetProperty failed");

    AudioStreamBasicDescription asbd;
    asbd.mSampleRate = kSampleRate;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    asbd.mFramesPerPacket = 1;
    asbd.mChannelsPerFrame = 1;
    asbd.mBitsPerChannel = 16;
    asbd.mBytesPerPacket = 2;
    asbd.mBytesPerFrame = 2;
    
    CheckError(AudioUnitSetProperty(player.outputUnit,
                               kAudioUnitProperty_StreamFormat,
                               kAudioUnitScope_Input,
                               0,
                               &asbd,
                               sizeof(asbd)),
                "Couldn't set description for stream");
    
    CheckError(AudioUnitInitialize(player.outputUnit),
                "Couldn't initialize output unit");
}

-(void)didFinishStreaming:(Buffer *)buffer {
    [self stop];
    [self.delegate didFinishStreaming:buffer];
}

-(void)stop {
    if (!self.streaming) return;
    self.streaming = NO;
    AudioOutputUnitStop(player.outputUnit);
    AudioUnitUninitialize(player.outputUnit);
    AudioComponentInstanceDispose(player.outputUnit);
}

@end