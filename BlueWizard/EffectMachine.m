#import "EffectMachine.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioHelpers.h"
#import "Buffer.h"

@interface EffectMachine ()
@property (nonatomic, strong) Buffer *buffer;
@end

typedef struct EffectMachineGraph {
    AUGraph   graph;
    AudioUnit input;
    AudioUnit lowpass;
    AudioUnit output;
} EffectMachineGraph;

@implementation EffectMachine {
    EffectMachineGraph machine;
}

-(instancetype)initWithBuffer:(Buffer *)buffer {
    if (self = [super init]) {
        self.buffer = buffer;
    }
    return self;
}

-(void)process {
    struct EffectMachineGraph initialized = {0};
    machine = initialized;
    
    CheckError(NewAUGraph(&machine.graph),
               "NewAUGraph failed");

    AudioComponentDescription outputCD = {0};
    outputCD.componentType = kAudioUnitType_Output;
    outputCD.componentSubType = kAudioUnitSubType_DefaultOutput;
    outputCD.componentManufacturer = kAudioUnitManufacturer_Apple;

    AUNode outputNode;
    CheckError(AUGraphAddNode(machine.graph,
                              &outputCD,
                              &outputNode),
               "AUGraphAddNode[kAudioUnitSubType_GenericOutput] failed");
    
    AudioComponentDescription inputCD = {0};
    inputCD.componentType = kAudioUnitType_Generator;
    inputCD.componentSubType = kAudioUnitSubType_ScheduledSoundPlayer;
    inputCD.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AUNode inputNode;
    CheckError(AUGraphAddNode(machine.graph,
                              &inputCD,
                              &inputNode),
               "AUGraphAddNode[kAudioUnitSubType_ScheduledSoundPlayer] failed");

    CheckError(AUGraphOpen(machine.graph),
               "AUGraphOpen failed");
    
    CheckError(AUGraphNodeInfo(machine.graph,
                               inputNode,
                               NULL,
                               &machine.input),
               "AUGraphNodeInfo failed");
    
    CheckError(AUGraphConnectNodeInput(machine.graph,
                                       inputNode,
                                       0,
                                       outputNode,
                                       0),
               "AUGraphConnectNodeInput");

    CheckError(AUGraphInitialize(machine.graph),
               "AUGraphInitialize failed");
    
    // prepare input

    AudioBufferList ioData = {0};
    ioData.mNumberBuffers = 1;
    ioData.mBuffers[0].mNumberChannels = 1;
    ioData.mBuffers[0].mDataByteSize = (UInt32)(2 * self.buffer.size);
    ioData.mBuffers[0].mData = self.buffer.samples;
    
    ScheduledAudioSlice slice = {0};
    AudioTimeStamp timeStamp  = {0};

    slice.mTimeStamp    = timeStamp;
    slice.mNumberFrames = (UInt32)self.buffer.size;
    slice.mBufferList   = &ioData;
    
    CheckError(AudioUnitSetProperty(machine.input,
                                    kAudioUnitProperty_ScheduleAudioSlice,
                                    kAudioUnitScope_Global,
                                    0,
                                    &slice,
                                    sizeof(slice)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduleStartTimeStamp] failed");
    
    AudioTimeStamp startTimeStamp = {0};
    startTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    startTimeStamp.mSampleTime = -1;
    
    CheckError(AudioUnitSetProperty(machine.input,
                                    kAudioUnitProperty_ScheduleStartTimeStamp,
                                    kAudioUnitScope_Global,
                                    0,
                                    &startTimeStamp,
                                    sizeof(startTimeStamp)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduleStartTimeStamp] failed");
    
    CheckError(AUGraphStart(machine.graph),
               "AUGraphStart failed");

//    AUGraphStop(machine.graph);
//    AUGraphUninitialize(machine.graph);
//    AUGraphClose(machine.graph);

}


@end
