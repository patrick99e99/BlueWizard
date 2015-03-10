#import "Input.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioHelpers.h"
#import "Buffer.h"

@interface Input ()
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, strong) Buffer *buffer;
@end

@implementation Input

-(instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        self.URL = URL;
    }
    return self;
}

-(Buffer *)buffer {
    if (!_buffer) {
        ExtAudioFileRef inputFile;

        CheckError(ExtAudioFileOpenURL((__bridge CFURLRef)self.URL,
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
        
        BOOL isStereo = asbd.mChannelsPerFrame == 2;
        
        ExtAudioFileRead(inputFile, &numberOfFrames, &ioData);
        
        double scale = 1.0f / (1 << 15);

        _buffer = [[Buffer alloc] initWithSize:numberOfFrames sampleRate:asbd.mSampleRate];

        for (int i = 0; i < numberOfFrames; i++) {
            NSUInteger index = isStereo ? i * 2 : i;
            SInt16 val = ((SInt16 *)ioData.mBuffers[0].mData)[index];
            if (asbd.mFormatFlags & kAudioFormatFlagIsBigEndian) {
                val = CFSwapInt16BigToHost(val);
            }
            _buffer.samples[i] = val * scale;
        }
    
        free(ioData.mBuffers[0].mData);
        ExtAudioFileDispose(inputFile);
    }

    return _buffer;
}

@end
