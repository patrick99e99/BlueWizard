#import "Processor.h"
#import "PreEmphasizer.h"
#import "HammingWindow.h"
#import "Segmenter.h"
#import "FrameData.h"
#import "Reflector.h"
#import "Autocorrelator.h"
#import "BitPacker.h"
#import "Buffer.h"
#import "SpeechSynthesizer.h"
#import "SpeechDataReader.h"
#import "UserSettings.h"
#import "PitchEstimator.h"
#import "NotificationNames.h"

@interface Processor ()
@property (nonatomic, strong) Buffer *buffer;
@end

@implementation Processor

+(instancetype)process:(Buffer *)buffer {
    Processor *processor = [[self alloc] init];
    [processor process:buffer];
    return processor;
}

-(void)process:(Buffer *)mainBuffer {
    if ([[self userSettings] preEmphasis]) {
        [PreEmphasizer processBuffer:mainBuffer];        
    }
    
    short *pitchTable;
    NSNumber *wrappedPitch;
    if ([[self userSettings] overridePitch]) {
        wrappedPitch = [[self userSettings] pitchValue];
    } else {
        pitchTable = [self pitchTableForBuffer:mainBuffer];
    }
    
    double *coefficients = malloc(sizeof(double) * 11);
    Segmenter *segmenter = [[Segmenter alloc] initWithBuffer:mainBuffer windowWidth:1];
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:[segmenter numberOfSegments]];
    [segmenter eachSegment:^(Buffer *buffer, NSUInteger index) {
        [HammingWindow processBuffer:buffer];

        [Autocorrelator getCoefficientsFor:coefficients forBuffer:buffer];
        
        Reflector *reflector = [Reflector translateCoefficients:coefficients numberOfSamples:buffer.size];

        NSUInteger pitch;
        if (wrappedPitch) {
            pitch = [wrappedPitch unsignedIntegerValue];
        } else {
            pitch = pitchTable[index];
        }
        
        FrameData *frameData = [[FrameData alloc] initWithReflector:reflector pitch:pitch repeat:NO translate:NO];
        
        [frames addObject:[frameData parameters]];
    }];
    free(coefficients);
    if (!wrappedPitch) free(pitchTable);

    [[NSNotificationCenter defaultCenter] postNotificationName:frameDataGenerated object:frames];

    NSString *byteStream = [BitPacker pack:frames];
    [[NSNotificationCenter defaultCenter] postNotificationName:byteStreamGenerated object:byteStream];

    NSArray *speechData = [SpeechDataReader speechDataFromString:byteStream];
    self.buffer = [SpeechSynthesizer processSpeechData:speechData];
    [[NSNotificationCenter defaultCenter] postNotificationName:bufferGenerated object:self.buffer];
}

-(short *)pitchTableForBuffer:(Buffer *)mainBuffer {
    Segmenter *segmenter = [[Segmenter alloc] initWithBuffer:mainBuffer windowWidth:2];

    short *pitchTable = malloc(sizeof(short) * [segmenter numberOfSegments]);
    
    [segmenter eachSegment:^(Buffer *buffer, NSUInteger index) {
        pitchTable[index] = [PitchEstimator pitchForPeriod:buffer];
    }];

    return pitchTable;
}

-(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

@end
