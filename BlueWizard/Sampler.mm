#import "Sampler.h"
#import <AudioToolbox/AudioToolbox.h>

typedef struct SamplerPlayer
{
    AudioUnit outputUnit;
    NSUInteger index;
    NSUInteger numberOfSamples;
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
        UInt16 sample = [[player->sampler.samples objectAtIndex:player->index] intValue];
        
        ((UInt16 *)ioData->mBuffers[0].mData)[i] = sample;
        
        player->index += 1;
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
    
    player = (SamplerPlayer){0};
    player.sampler = self;
    player.numberOfSamples = [self.samples count];
        
    CreateAndConnectOutputUnit(&player);

    CheckError (AudioOutputUnitStart(player.outputUnit), "Couldn't start output unit");
}

static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char str[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
    exit(1);
}

void CreateAndConnectOutputUnit (SamplerPlayer *player) {
    
    AudioComponentDescription outputcd = {0}; // 10.6 version
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_DefaultOutput;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    
    AudioComponent comp = AudioComponentFindNext (NULL, &outputcd);
    if (comp == NULL) {
        printf ("can't get output unit");
        exit (-1);
    }
    AudioComponentInstanceNew(comp, &player->outputUnit);
    
    // register render callback
    AURenderCallbackStruct input;
    input.inputProc = CallbackRenderProc;
    input.inputProcRefCon = player;
    
    CheckError(AudioUnitSetProperty(player->outputUnit,
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Input,
                                    0,
                                    &input,
                                    sizeof(input)),
               "AudioUnitSetProperty failed");
    
    AudioStreamBasicDescription asbd;
    asbd.mSampleRate = 8000.0;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger;//kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsNonMixable;
    asbd.mFramesPerPacket = 1;
    asbd.mChannelsPerFrame = 1;
    asbd.mBitsPerChannel = 16;
    asbd.mBytesPerPacket = 2;
    asbd.mBytesPerFrame = 2;
    
    OSStatus err;
    
    err = AudioUnitSetProperty(player->outputUnit,
                               kAudioUnitProperty_StreamFormat,
                               kAudioUnitScope_Input,
                               0,
                               &asbd,
                               sizeof(asbd));
    
    CheckError (AudioUnitInitialize(player->outputUnit),
                "Couldn't initialize output unit");
    
}

-(void)stop {
    AudioOutputUnitStop(player.outputUnit);
    AudioUnitUninitialize(player.outputUnit);
    AudioComponentInstanceDispose(player.outputUnit);
}

@end