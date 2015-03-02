#import "Input.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Sampler.h"
#import "AudioHelpers.h"

#define kInputFileLocation	CFSTR("/Users/patrick/Desktop/booberry.aif")

typedef struct MyAudioConverterSettings
{
    AudioStreamBasicDescription outputFormat; // output file's data stream description
    
    ExtAudioFileRef				inputFile; // reference to your input file
    AudioFileID					outputFile; // reference to your output file
    
} MyAudioConverterSettings;

@interface Input ()
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, weak) Sampler *sampler;
@end

@implementation Input

-(instancetype)initWithSampler:(Sampler *)sampler URL:(NSURL *)url {
    if (self = [super init]) {
        self.sampler = sampler;
        self.url = url;
        [self loadBuffer];
    }
    return self;
}

-(void)loadBuffer {
    ExtAudioFileRef inputFile;

    CheckError(ExtAudioFileOpenURL((__bridge CFURLRef)self.url,
                                    &inputFile),
                "ExtAudioFileOpenURL failed");
    
    AudioStreamBasicDescription asbd;
    UInt32 propSize = sizeof(asbd);
    CheckError(ExtAudioFileGetProperty(inputFile, kExtAudioFileProperty_FileDataFormat, &propSize, &asbd), "get description failed");
    
    UInt32 numberOfFrames = 0;
    propSize = sizeof(SInt64);
    CheckError(ExtAudioFileGetProperty(inputFile, kExtAudioFileProperty_FileLengthFrames, &propSize, &numberOfFrames), "GetProperty failed");

    AudioBufferList ioData = {0};
    ioData.mNumberBuffers = 1;
    ioData.mBuffers[0].mNumberChannels = 1;
    ioData.mBuffers[0].mDataByteSize = asbd.mBytesPerPacket * numberOfFrames;
    ioData.mBuffers[0].mData = malloc(ioData.mBuffers[0].mDataByteSize);
    
    ExtAudioFileRead(inputFile, &numberOfFrames, &ioData);
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:numberOfFrames];

    float scale = 1.0f / (1 << 15);
    for (int i = 0; i < numberOfFrames; i++) {
        SInt16 val = ((SInt16 *)ioData.mBuffers[0].mData)[i];

        if (asbd.mFormatFlags & kAudioFormatFlagIsBigEndian) {
            val = CFSwapInt16BigToHost(val);
        }
        [arr addObject:[NSNumber numberWithFloat:(val * scale)]];
    }
    
    [self.sampler stream:[arr copy] sampleRate:48000];

    free(ioData.mBuffers[0].mData);
    ExtAudioFileDispose(inputFile);
}

@end
