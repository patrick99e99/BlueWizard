#import "EffectMachine.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioHelpers.h"
#import "Buffer.h"

@interface EffectMachine ()
@property (nonatomic, strong) Buffer *buffer;
@end

typedef struct MyAUGraphPlayer
{
    AudioStreamBasicDescription inputFormat; // input file's data stream description
    AudioFileID					inputFile; // reference to your input file
    
    AUGraph graph;
    AudioUnit fileAU;
    AudioUnit lowPassAU;
    
} MyAUGraphPlayer;

@implementation EffectMachine {
}

-(instancetype)initWithBuffer:(Buffer *)buffer {
    if (self = [super init]) {
        self.buffer = buffer;
    }
    return self;

}
-(void)process {
    CFURLRef inputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFSTR ("/Users/patrick/Desktop/tms_stuff/save-keys.aif"), kCFURLPOSIXPathStyle, false);
    MyAUGraphPlayer player = {0};
    
    // open the input audio file
    CheckError(AudioFileOpenURL(inputFileURL, kAudioFileReadPermission, 0, &player.inputFile),
               "AudioFileOpenURL failed");
    CFRelease(inputFileURL);
    
    // get the audio data format from the file
    UInt32 propSize = sizeof(player.inputFormat);
    CheckError(AudioFileGetProperty(player.inputFile, kAudioFilePropertyDataFormat,
                                    &propSize, &player.inputFormat),
               "couldn't get file's data format");
    
    // build a basic fileplayer->speakers graph
    // create a new AUGraph
    CheckError(NewAUGraph(&player.graph),
               "NewAUGraph failed");
    
    // generate description that will match out output device (speakers)
    AudioComponentDescription outputcd = {0};
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_DefaultOutput;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // adds a node with above description to the graph
    AUNode outputNode;
    CheckError(AUGraphAddNode(player.graph, &outputcd, &outputNode),
               "AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed");
    
    // generate description that will match a generator AU of type: audio file player
    AudioComponentDescription fileplayercd = {0};
    fileplayercd.componentType = kAudioUnitType_Generator;
    fileplayercd.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    fileplayercd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // adds a node with above description to the graph
    AUNode fileNode;
    CheckError(AUGraphAddNode(player.graph, &fileplayercd, &fileNode),
               "AUGraphAddNode[kAudioUnitSubType_AudioFilePlayer] failed");
    
    // opening the graph opens all contained audio units but does not allocate any resources yet
    CheckError(AUGraphOpen(player.graph),
               "AUGraphOpen failed");
    
    
    // get the reference to the AudioUnit object for the file player graph node
    CheckError(AUGraphNodeInfo(player.graph, fileNode, NULL, &player.fileAU),
               "AUGraphNodeInfo failed");
    
    AudioComponentDescription lowpasscd = {0};
    lowpasscd.componentType = kAudioUnitType_Effect;
    lowpasscd.componentSubType = kAudioUnitSubType_LowPassFilter;
    lowpasscd.componentManufacturer = kAudioUnitManufacturer_Apple;

    AUNode lowPassNode;
    CheckError(AUGraphAddNode(player.graph, &lowpasscd, &lowPassNode),
               "AUGraphAddNode[kAudioUnitSubType_LowPassFilter] failed");

    
    // get the reference to the AudioUnit object for the file player graph node
    CheckError(AUGraphNodeInfo(player.graph, lowPassNode, NULL, &player.lowPassAU),
               "AUGraphNodeInfo failed");
    
    CheckError(AudioUnitSetParameter(player.lowPassAU,
                                     kLowPassParam_CutoffFrequency,
                                     kAudioUnitScope_Global,
                                     0,
                                     125,
                                     0), "AudioUnitSetParameter for lowpass failed");
    
    // connect the output source of the file player AU to the input source of the output node
    CheckError(AUGraphConnectNodeInput(player.graph, fileNode, 0, lowPassNode, 0),
               "AUGraphConnectNodeInput");

    
    // connect the output source of the file player AU to the input source of the output node
    CheckError(AUGraphConnectNodeInput(player.graph, lowPassNode, 0, outputNode, 0),
               "AUGraphConnectNodeInput");
    
    // now initialize the graph (causes resources to be allocated)
    CheckError(AUGraphInitialize(player.graph),
               "AUGraphInitialize failed");
    
    // configure the file player
    
    
    // tell the file player unit to load the file we want to play
    CheckError(AudioUnitSetProperty(player.fileAU, kAudioUnitProperty_ScheduledFileIDs,
                                    kAudioUnitScope_Global, 0, &player.inputFile, sizeof(player.inputFile)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileIDs] failed");
    
    UInt64 nPackets;
    UInt32 propsize = sizeof(nPackets);
    CheckError(AudioFileGetProperty(player.inputFile, kAudioFilePropertyAudioDataPacketCount,
                                    &propsize, &nPackets),
               "AudioFileGetProperty[kAudioFilePropertyAudioDataPacketCount] failed");
    
    // tell the file player AU to play the entire file
    ScheduledAudioFileRegion rgn;
    memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = player.inputFile;
    rgn.mLoopCount = 1;
    rgn.mStartFrame = 0;
    rgn.mFramesToPlay = nPackets * player.inputFormat.mFramesPerPacket;
    
    CheckError(AudioUnitSetProperty(player.fileAU, kAudioUnitProperty_ScheduledFileRegion,
                                    kAudioUnitScope_Global, 0,&rgn, sizeof(rgn)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileRegion] failed");
    
    // prime the file player AU with default values
    UInt32 defaultVal = 0;
    CheckError(AudioUnitSetProperty(player.fileAU, kAudioUnitProperty_ScheduledFilePrime,
                                    kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduledFilePrime] failed");
    
    // tell the file player AU when to start playing (-1 sample time means next render cycle)
    AudioTimeStamp startTime;
    memset (&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1;
    CheckError(AudioUnitSetProperty(player.fileAU, kAudioUnitProperty_ScheduleStartTimeStamp,
                                    kAudioUnitScope_Global, 0, &startTime, sizeof(startTime)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduleStartTimeStamp]");
    
    
    
    // start playing
    CheckError(AUGraphStart(player.graph),
               "AUGraphStart failed");
    
    // sleep until the file is finished

//    AUGraphStop (player.graph);
//    AUGraphUninitialize (player.graph);
//    AUGraphClose(player.graph);
//    AudioFileClose(player.inputFile);
}


@end
