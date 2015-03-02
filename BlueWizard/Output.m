#import "Output.h"
#import <AppKit/AppKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioHelpers.h"

@implementation Output

+(void)save:(NSArray *)buffer {
    NSSavePanel *save = [NSSavePanel savePanel];
    
    NSInteger result = [save runModal];
    
    if (result == NSModalResponseOK) {
        [self createAIFFileFrom:buffer URL:[save URL]];
    }
}

+(void)createAIFFileFrom:(NSArray *)buffer URL:(NSURL *)URL {
    AudioStreamBasicDescription asbd = {0};
    
    asbd.mSampleRate = 48000.0f;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian;
    asbd.mFramesPerPacket = 1;
    asbd.mChannelsPerFrame = 1;
    asbd.mBitsPerChannel = 16;
    asbd.mBytesPerPacket = 2;
    asbd.mBytesPerFrame = 2;
    
    AudioFileID file;
    CheckError(AudioFileCreateWithURL((__bridge CFURLRef)URL,
                                      kAudioFileAIFFType, &asbd,
                                      kAudioFileFlags_EraseFile,
                                      &file),
               "AudioFileCreateWithURL failed");

    int inputSamples = (int)[buffer count];
    UInt32 outputSamples = (UInt32)inputSamples * 6;
    AudioBufferList ioData = {0};
    ioData.mNumberBuffers = 1;
    ioData.mBuffers[0].mNumberChannels = 1;
    ioData.mBuffers[0].mDataByteSize = asbd.mBytesPerPacket * outputSamples;
    ioData.mBuffers[0].mData = malloc(ioData.mBuffers[0].mDataByteSize);
    
    NSUInteger scale = (1 << 15);
    NSUInteger index = 0;
    NSUInteger i = 0;
    while (i < inputSamples) {
        SInt16 sample = (SInt16)([[buffer objectAtIndex:i] floatValue] * scale);
        sample = CFSwapInt16HostToBig(sample);
        ((SInt16 *)ioData.mBuffers[0].mData)[index] = sample;
        index += 1;
        if (!(index % 6)) {
            i += 1;
        }
    }
    
    CheckError(AudioFileWritePackets(file,
                                     FALSE,
                                     ioData.mBuffers[0].mDataByteSize,
                                     NULL,
                                     0,
                                     &outputSamples,
                                     ioData.mBuffers[0].mData),
               "AudioFileWritePackets failed");

    free(ioData.mBuffers[0].mData);
    AudioFileClose(file);
}

@end
