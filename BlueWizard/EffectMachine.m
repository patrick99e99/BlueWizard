#import "EffectMachine.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioHelpers.h"
#import "Buffer.h"

@interface EffectMachine ()
@property (nonatomic, strong) Buffer *buffer;
@end

typedef struct SamplerPlayer {
    NSUInteger index;
    AUGraph graph;
    AudioUnit inputUnit;
    AudioUnit lowPassAU;
    AudioUnit outputUnit;
    __unsafe_unretained Buffer *buffer;
} SamplerPlayer;

OSStatus EffectMachineCallbackRenderProc(void *inRefCon,
                            AudioUnitRenderActionFlags *ioActionFlags,
                            const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber,
                            UInt32 inNumberFrames,
                            AudioBufferList * ioData);

OSStatus EffectMachineCallbackRenderProc(void *inRefCon,
                            AudioUnitRenderActionFlags *ioActionFlags,
                            const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber,
                            UInt32 inNumberFrames,
                            AudioBufferList * ioData) {
    struct SamplerPlayer *player = (struct SamplerPlayer *)inRefCon;
    if (player->index == player->buffer.size - 1) return noErr;
    
    for (int i = 0; i < inNumberFrames; i++) {
        float sample = (float)player->buffer.samples[player->index];
        ((float *)ioData->mBuffers[0].mData)[i] = sample;
        
        if (player->index == player->buffer.size - 1) {
            break;
        }
        player->index += 1;
    }
    
    return noErr;
}

@implementation EffectMachine {
    SamplerPlayer player;
}

-(instancetype)initWithBuffer:(Buffer *)buffer {
    if (self = [super init]) {
        self.buffer = buffer;
    }
    return self;
}

-(void)process {
    struct SamplerPlayer initialized = {0};
    player = initialized;
    player.buffer = self.buffer;

    [self createAndConnectOutputUnit];
}

-(void)createAndConnectOutputUnit {
    CheckError(NewAUGraph(&player.graph),
               "NewAUGraph failed");

    CheckError(AUGraphOpen(player.graph),
               "AUGraphOpen failed");

    AudioComponentDescription outputcd = {0};
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_DefaultOutput;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AUNode outputNode;
    CheckError(AUGraphAddNode(player.graph, &outputcd, &outputNode),
               "AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed");
    
    AUNode inputNode;
    AUGraphNodeInfo(player.graph, inputNode, NULL, &player.inputUnit);
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = EffectMachineCallbackRenderProc;
    callbackStruct.inputProcRefCon = &player;
    
    AudioUnitSetProperty (
                          player.inputUnit,
                          kAudioUnitProperty_SetRenderCallback,
                          kAudioUnitScope_Input,
                          0,
                          &callbackStruct,
                          sizeof (callbackStruct));
    
//    AudioComponentDescription lowpasscd = {0};
//    lowpasscd.componentType = kAudioUnitType_Effect;
//    lowpasscd.componentSubType = kAudioUnitSubType_LowPassFilter;
//    lowpasscd.componentManufacturer = kAudioUnitManufacturer_Apple;
//
//    AUNode lowPassNode;
//    CheckError(AUGraphAddNode(player.graph, &lowpasscd, &lowPassNode),
//               "AUGraphAddNode[kAudioUnitSubType_LowPassFilter] failed");
//
//    CheckError(AUGraphNodeInfo(player.graph, lowPassNode, NULL, &player.lowPassAU),
//               "AUGraphNodeInfo failed");
//
//    CheckError(AudioUnitSetParameter(player.lowPassAU,
//                                     kLowPassParam_CutoffFrequency,
//                                     kAudioUnitScope_Global,
//                                     0,
//                                     125,
//                                     0), "AudioUnitSetParameter for lowpass failed");
//
//    AUGraphConnectNodeInput (
//                             player.graph,
//                             inputNode,
//                             0,
//                             lowPassNode,
//                             0
//                             );
//    
//    AUGraphConnectNodeInput (
//                             player.graph,
//                             lowPassNode,
//                             0,
//                             outputNode,
//                             0
//                             );
    
    AUGraphConnectNodeInput (
                             player.graph,
                             inputNode,
                             0,
                             outputNode,
                             0
                             );
    
    
    AudioStreamBasicDescription asbd;
    asbd.mSampleRate = self.buffer.sampleRate;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsFloat;
    asbd.mFramesPerPacket = 1;
    asbd.mChannelsPerFrame = 1;
    asbd.mBitsPerChannel = 32;
    asbd.mBytesPerPacket = 2;
    asbd.mBytesPerFrame = 2;
    
    CheckError(AudioUnitSetProperty(player.outputUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    0,
                                    &asbd,
                                    sizeof(asbd)),
               "Couldn't set description for stream");
    
    
    CheckError(AUGraphInitialize(player.graph),
               "AUGraphInitialize failed");
    
    CheckError(AUGraphStart(player.graph),
               "AUGraphStart failed");
    
    ////    AUGraphStop (player.graph);
    ////    AUGraphUninitialize (player.graph);
    ////    AUGraphClose(player.graph);
}

@end
