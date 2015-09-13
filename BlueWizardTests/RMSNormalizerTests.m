#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "RMSNormalizer.h"
#import "Reflector.h"
#import "CodingTable.h"
#import "UserSettings.h"
#import "FrameData.h"
#import <OCMock.h>

@interface RMSNormalizer (Stubs)
-(NSUInteger)maxRMSIndex;
@end

@interface RMSNormalizerTests : XCTestCase

@end

@implementation RMSNormalizerTests

-(void)setUp {
    [super setUp];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testItNormalizesRMSValues {
    Reflector *reflector = [[Reflector alloc] init];
    reflector.rms = [CodingTable rms][2];
    XCTAssertEqualWithAccuracy(reflector.rms, [CodingTable rms][2], 1.0f);

    id classMock = OCMClassMock([RMSNormalizer class]);
    OCMStub([classMock maxRMSIndex]).andReturn(3);
    
    FrameData *frameData = [[FrameData alloc] initWithReflector:reflector pitch:0 repeat:NO];
    [RMSNormalizer normalizeVoiced:@[frameData]];

    XCTAssertEqualWithAccuracy(reflector.rms, [CodingTable rms][3], 1.0f);
}

@end
