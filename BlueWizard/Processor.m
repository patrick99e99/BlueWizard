#import "Processor.h"
#import "PreEmphasizer.h"
#import "HammingWindow.h"
#import "Segmenter.h"
#import "FrameData.h"
#import "Reflector.h"
#import "Autocorrelator.h"
#import "BitPacker.h"
#import "Buffer.h"

@implementation Processor

+(void)process:(Buffer *)mainBuffer {
    [PreEmphasizer processBuffer:mainBuffer];
    Segmenter *segmenter = [[Segmenter alloc] initWithBuffer:mainBuffer windowWidth:1];
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:[segmenter numberOfSegments]];
    [segmenter eachSegment:^(Buffer *buffer, NSUInteger index) {
        [HammingWindow processBuffer:buffer];
        float coefficients[] = {0};
        [Autocorrelator getCoefficientsFor:coefficients forBuffer:buffer];
        Reflector *reflector = [Reflector translateCoefficients:coefficients numberOfSamples:buffer.size];
        FrameData *frameData = [[FrameData alloc] initWithReflector:reflector pitch:0 repeat:NO translate:NO];
        [frames addObject:frameData];
    }];
    
    NSString *hexStream = [BitPacker pack:frames];
    NSLog(@"hex: %@", hexStream);
}

@end
