#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "Buffer.h"

@interface BufferTests : XCTestCase

@end

@implementation BufferTests {
    Buffer *subject;
    double *samples;
}

-(void)setUp {
    [super setUp];
    samples = malloc(sizeof(double) * 3);
    samples[0] = 2.0f;
    samples[1] = 3.0f;
    samples[2] = 4.0f;
    subject = [[Buffer alloc] initWithSamples:samples size:3 sampleRate:8000];
}

-(void)tearDown {
    free(samples);
    [super tearDown];
}

-(void)testItCopiesTheSamples {
    XCTAssertEqual(subject.samples[0], 2.0f);
    XCTAssertEqual(subject.samples[1], 3.0f);
    XCTAssertEqual(subject.samples[2], 4.0f);
}

-(void)testItKnowsItsSize {
    XCTAssertEqual(subject.size, 3);
}

-(void)testItKnowsItsEnergy {
    XCTAssertEqual([subject energy], 29.0f);
}

-(void)testItKnowsItsSampleRate {
    XCTAssertEqual([subject sampleRate], 8000);
}

-(void)testItCanBeCopied {
    Buffer *buffer = [subject copy];

    XCTAssertEqual(buffer.samples[0], 2.0f);
    XCTAssertEqual(buffer.samples[1], 3.0f);
    XCTAssertEqual(buffer.samples[2], 4.0f);
    XCTAssertEqual(buffer.size, 3);
    XCTAssertEqual([buffer energy], 29.0f);
    XCTAssertEqual([buffer sampleRate], 8000);

    buffer.samples[0] = 1.0f;
    
    XCTAssertEqual(subject.samples[0], 2.0f);
}

@end
