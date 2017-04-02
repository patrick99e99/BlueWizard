#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "Segmenter.h"
#import "Buffer.h"
#import "UserSettings.h"

@interface SegmenterTests : XCTestCase

@end

@implementation SegmenterTests {
    Segmenter *subject;
    Buffer *mainBuffer;
    double *samples;
}

-(void)setUp {
    [super setUp];
    NSUInteger size = 30;
    samples = malloc(sizeof(float) * size);
    for (int i = 0; i < size; i++) {
        samples[i] = 1.0f;
    }
    
    mainBuffer = [[Buffer alloc] initWithSamples:samples size:size sampleRate:8000];
    [[UserSettings sharedInstance] setFrameRate:@1];
    subject = [[Segmenter alloc] initWithBuffer:mainBuffer windowWidth:1];
}

-(void)tearDown {
    [super tearDown];
    free(samples);
}

-(void)testItYieldsBuffers {
    __block int sum = 0;
    [subject eachSegment:^(Buffer *buffer, NSUInteger index) {
        for (int i = 0; i < buffer.size; i++) {
            sum += buffer.samples[i];
        }
    }];

    XCTAssertEqual(sum, 30);
}

@end
