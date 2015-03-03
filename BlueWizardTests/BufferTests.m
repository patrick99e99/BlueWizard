#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "Buffer.h"

@interface BufferTests : XCTestCase

@end

@implementation BufferTests {
    Buffer *subject;
}

-(void)setUp {
    [super setUp];
    float samples[] = { 2.0f, 3.0f, 4.0f };
    subject = [[Buffer alloc] initWithSamples:samples size:3];
}

-(void)tearDown {
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

@end
