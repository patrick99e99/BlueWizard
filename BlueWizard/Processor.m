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
#import "Sampler.h"
#import "SpeechDataReader.h"
#import "UserSettings.h"
#import "PitchEstimator.h"

@interface Processor ()
@property (nonatomic, strong) Sampler *sampler;
@property (nonatomic, strong) Buffer *buffer;

@end

@implementation Processor

+(instancetype)process:(Buffer *)buffer {
    Processor *processor = [[self alloc] init];
    [processor process:buffer];
    return processor;
}

-(void)process:(Buffer *)mainBuffer {
//    [PreEmphasizer processBuffer:mainBuffer];
    
    short *pitchTable = [self pitchTableForBuffer:mainBuffer];
    
//    NSUInteger pitch = [[UserSettings sharedInstance] pitchValue];
    double *coefficients = malloc(sizeof(double) * 11);
    Segmenter *segmenter = [[Segmenter alloc] initWithBuffer:mainBuffer windowWidth:1];
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:[segmenter numberOfSegments]];
    [segmenter eachSegment:^(Buffer *buffer, NSUInteger index) {
        [HammingWindow processBuffer:buffer];

        [Autocorrelator getCoefficientsFor:coefficients forBuffer:buffer];
        
        Reflector *reflector = [Reflector translateCoefficients:coefficients numberOfSamples:buffer.size];
        
        FrameData *frameData = [[FrameData alloc] initWithReflector:reflector pitch:pitchTable[index] repeat:NO translate:NO];
        
        [frames addObject:[frameData parameters]];
    }];
    free(coefficients);
    free(pitchTable);

    NSArray *speechData = [SpeechDataReader speechDataFromString:[BitPacker pack:frames]];
    self.buffer = [SpeechSynthesizer processSpeechData:speechData];
    [self.sampler stream:self.buffer];
}

-(short *)pitchTableForBuffer:(Buffer *)mainBuffer {
    Segmenter *segmenter = [[Segmenter alloc] initWithBuffer:mainBuffer windowWidth:2];

    short *pitchTable = malloc(sizeof(short) * [segmenter numberOfSegments]);
    
    [segmenter eachSegment:^(Buffer *buffer, NSUInteger index) {
        pitchTable[index] = [PitchEstimator pitchForPeriod:buffer];
    }];

    return pitchTable;
}

-(Sampler *)sampler {
    if (!_sampler) {
        _sampler = [[Sampler alloc] initWithDelegate:nil];
    }
    return _sampler;
}


@end
