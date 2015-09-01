#import "Filterer.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioHelpers.h"
#import "Buffer.h"

@interface Filterer ()
@property (nonatomic, strong) Buffer *buffer;
@property (nonatomic) NSUInteger lowPassCutoffInHZ;
@property (nonatomic) NSUInteger highPassCutoffInHZ;
@end

typedef struct FilterPlayer {
    NSUInteger index;
    AudioUnit lowPassUnit;
    AudioUnit highPassUnit;
    __unsafe_unretained Buffer *buffer;
} FilterPlayer;

OSStatus FiltererCallbackRenderProc(void *inRefCon,
                                         AudioUnitRenderActionFlags *ioActionFlags,
                                         const AudioTimeStamp *inTimeStamp,
                                         UInt32 inBusNumber,
                                         UInt32 inNumberFrames,
                                         AudioBufferList * ioData);

OSStatus FiltererCallbackRenderProc(void *inRefCon,
                                         AudioUnitRenderActionFlags *ioActionFlags,
                                         const AudioTimeStamp *inTimeStamp,
                                         UInt32 inBusNumber,
                                         UInt32 inNumberFrames,
                                         AudioBufferList * ioData) {
    struct FilterPlayer *player = (struct FilterPlayer *)inRefCon;
    
    for (int i = 0; i < inNumberFrames; i++) {
        float sample;
        if (player->index < player->buffer.size) {
            sample = (float)player->buffer.samples[player->index];
            player->index += 1;
        } else {
            sample = 0;
        }
        ((float *)ioData->mBuffers[0].mData)[i] = sample;
        ((float *)ioData->mBuffers[1].mData)[i] = sample;
    }
    
    return noErr;
}

@implementation Filterer {
    FilterPlayer player;
}

-(instancetype)initWithBuffer:(Buffer *)buffer
            lowPassCutoffInHZ:(NSUInteger)lowPassCutoffInHZ
           highPassCutoffInHZ:(NSUInteger)highPassCutoffInHZ {
    if (self = [super init]) {
        self.buffer = buffer;
        self.lowPassCutoffInHZ  = lowPassCutoffInHZ;
        self.highPassCutoffInHZ = highPassCutoffInHZ;
    }
    return self;
}

-(Buffer *)process {
    struct FilterPlayer initialized = {0};
    player        = initialized;
    player.buffer = self.buffer;
    
    [self setupAudioUnits];
    Buffer *buffer = [self processedBuffer];
    [self cleanup];
    
    return buffer;
}

-(void)setupAudioUnits {
    AudioComponent comp;
    
    AudioComponentDescription lowpasscd = {0};
    lowpasscd.componentType = kAudioUnitType_Effect;
    lowpasscd.componentSubType = kAudioUnitSubType_LowPassFilter;
    lowpasscd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    comp = AudioComponentFindNext(NULL, &lowpasscd);
    if (comp == NULL) NSLog(@"can't get lowpass unit");
    
    AudioComponentInstanceNew(comp, &player.lowPassUnit);
    
    AudioComponentDescription highpasscd = {0};
    highpasscd.componentType = kAudioUnitType_Effect;
    highpasscd.componentSubType = kAudioUnitSubType_HighPassFilter;
    highpasscd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    comp = AudioComponentFindNext(NULL, &highpasscd);
    if (comp == NULL) NSLog(@"can't get lowpass unit");
    
    AudioComponentInstanceNew(comp, &player.highPassUnit);

    AURenderCallbackStruct input;
    input.inputProc = FiltererCallbackRenderProc;
    input.inputProcRefCon = &player;
    
    CheckError(AudioUnitSetProperty(player.lowPassUnit,
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Input,
                                    0,
                                    &input,
                                    sizeof(input)),
               "AudioUnitSetProperty for callback failed");
    
    CheckError(AudioUnitSetParameter(player.lowPassUnit,
                                     kLowPassParam_CutoffFrequency,
                                     kAudioUnitScope_Global,
                                     0,
                                     self.lowPassCutoffInHZ,
                                     0), "AudioUnitSetParameter cutoff for lowpass failed");
    
    CheckError(AudioUnitSetParameter(player.lowPassUnit,
                                     kLowPassParam_Resonance,
                                     kAudioUnitScope_Global,
                                     0,
                                     0,
                                     0), "AudioUnitSetParameter resonance for lowpass failed");
    
    CheckError(AudioUnitSetParameter(player.highPassUnit,
                                     kHipassParam_CutoffFrequency,
                                     kAudioUnitScope_Global,
                                     0,
                                     self.highPassCutoffInHZ,
                                     0), "AudioUnitSetParameter cutoff for highpass failed");
    
    CheckError(AudioUnitSetParameter(player.highPassUnit,
                                     kHipassParam_Resonance,
                                     kAudioUnitScope_Global,
                                     0,
                                     0,
                                     0), "AudioUnitSetParameter resonance for highpass failed");
    
    AudioUnitConnection connection = {0};
    connection.destInputNumber = 0;
    connection.sourceAudioUnit = player.lowPassUnit;
    connection.sourceOutputNumber = 0;
    AudioUnitSetProperty(player.highPassUnit,
                         kAudioUnitProperty_MakeConnection,
                         kAudioUnitScope_Input,
                         0,
                         &connection,
                         sizeof(AudioUnitConnection));

    CheckError(AudioUnitInitialize(player.lowPassUnit),
               "Couldn't initialize lowpass unit");
    
    CheckError(AudioUnitInitialize(player.highPassUnit),
               "Couldn't initialize lowpass unit");
}

-(Buffer *)processedBuffer {
    AudioBufferList *bufferlist = calloc(1, offsetof(AudioBufferList, mBuffers) + (sizeof(AudioBuffer) * 2));
    UInt32 blockSize = 1024;
    float *left = malloc(sizeof(float) * blockSize);
    float *right = malloc(sizeof(float) * blockSize);
    
    bufferlist->mBuffers[0].mData = left;
    bufferlist->mBuffers[1].mData = right;
    UInt32 size = sizeof(float) * blockSize;
    
    AudioTimeStamp inTimeStamp;
    memset(&inTimeStamp, 0, sizeof(AudioTimeStamp));
    inTimeStamp.mSampleTime = 0;
    
    AudioUnitRenderActionFlags flag = 0;
    
    NSUInteger length = ceil(self.buffer.size / (float)blockSize);
    
    double *processed = malloc(sizeof(double) * blockSize * length);
    
    for (int i = 0; i < length; i++) {
        bufferlist->mBuffers[0].mDataByteSize = size;
        bufferlist->mBuffers[1].mDataByteSize = size;
        bufferlist->mNumberBuffers = 2;
        inTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;

        AudioUnitRender(player.highPassUnit, &flag, &inTimeStamp, 0, blockSize, bufferlist);
        for (NSUInteger j = 0; j < blockSize; j++) {
            processed[j + (blockSize * i)] = left[j];
        }
        inTimeStamp.mSampleTime += blockSize;
    }
    
    Buffer *buffer = [[Buffer alloc] initWithSamples:processed size:self.buffer.size sampleRate:self.buffer.sampleRate];
    
    free(bufferlist);
    free(left);
    free(right);
    free(processed);
    
    return buffer;
}

-(void)cleanup {
    AudioOutputUnitStop(player.lowPassUnit);
    AudioUnitUninitialize(player.lowPassUnit);
    AudioComponentInstanceDispose(player.lowPassUnit);
}

@end