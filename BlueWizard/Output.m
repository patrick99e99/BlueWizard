#import "Output.h"
#import <AppKit/AppKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioHelpers.h"
#import "Buffer.h"
#import "UserSettings.h"

@implementation Output

+(void)createAIFFileFrom:(Buffer *)buffer URL:(NSURL *)URL {
    AudioStreamBasicDescription asbd = {0};
    
    asbd.mSampleRate = [[[UserSettings sharedInstance] exportSampleRate] floatValue];
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

    float ratio = buffer.sampleRate / asbd.mSampleRate;
    
    UInt32 outputSamples = (UInt32)buffer.size * ceil(asbd.mSampleRate / buffer.sampleRate);
    AudioBufferList ioData = {0};
    ioData.mNumberBuffers = 1;
    ioData.mBuffers[0].mNumberChannels = 1;
    ioData.mBuffers[0].mDataByteSize = asbd.mBytesPerPacket * outputSamples;
    ioData.mBuffers[0].mData = malloc(ioData.mBuffers[0].mDataByteSize);

    NSUInteger scale = (1 << 15);
    NSUInteger i = 0;
    NSUInteger index = 0;
    while (index < buffer.size) {
        SInt16 sample = buffer.samples[index] * scale;
        sample = CFSwapInt16HostToBig(sample);
        ((SInt16 *)ioData.mBuffers[0].mData)[i] = sample;
        i += 1;
        index = floor(i * ratio);
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
