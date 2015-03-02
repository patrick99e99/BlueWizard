#import "Sampler.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioHelpers.h"

typedef struct SamplerPlayer
{
    AudioUnit outputUnit;
    NSUInteger index;
    NSUInteger counter;
    NSUInteger numberOfSamples;
    NSUInteger sampleRate;
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
                            AudioBufferList * ioData)
{
    struct SamplerPlayer *player = (struct SamplerPlayer *)inRefCon;
    
    if (player->numberOfSamples <= player->index) {
        [player->sampler performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:NO];
    }
    
    for (int i = 0; i < inNumberFrames; i++) {
        SInt16 sample = [[player->sampler.samples objectAtIndex:player->index] floatValue] * (1 << 15);
        
        ((SInt16 *)ioData->mBuffers[0].mData)[i] = sample;
        
        if ((player->sampleRate == 8000 && !(player->counter % 6)) || player->sampleRate == 48000) {
            player->index += 1;
        }
        player->counter += 1;
    }
    
    return noErr;
}

@interface Sampler ()

@property (nonatomic, copy) NSArray *samples;

@end

@implementation Sampler {
    SamplerPlayer player;
}

-(void)stream:(NSArray *)samples sampleRate:(NSUInteger)sampleRate {
    [self stop];

    self.samples = samples;
    
    player                 = (SamplerPlayer){0};
    player.sampler         = self;
    player.sampleRate      = sampleRate;
    player.numberOfSamples = [self.samples count];
    
    [self createAndConnectOutputUnitWithSampleRate:48000];

    CheckError(AudioOutputUnitStart(player.outputUnit), "Couldn't start output unit");
}

-(void)createAndConnectOutputUnitWithSampleRate:(NSUInteger)sampleRate {
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
    asbd.mSampleRate = sampleRate;
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

-(void)stop {
    AudioOutputUnitStop(player.outputUnit);
    AudioUnitUninitialize(player.outputUnit);
    AudioComponentInstanceDispose(player.outputUnit);
}

@end