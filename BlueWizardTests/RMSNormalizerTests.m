#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "RMSNormalizer.h"
#import "Reflector.h"
#import "CodingTable.h"
#import "UserSettings.h"
#import "FrameData.h"

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
    NSUInteger maxIndex = [CodingTable rmsSize] - 1;
    XCTAssertNotEqual(reflector.rms, [CodingTable rms][maxIndex]);

    [UserSettings sharedInstance].maxRMSIndex = @(maxIndex);
    FrameData *frameData = [[FrameData alloc] initWithReflector:reflector pitch:0 repeat:NO];
    [RMSNormalizer normalize:@[frameData]];

    XCTAssertEqualWithAccuracy(reflector.rms, [CodingTable rms][maxIndex], 1.0f);
}

@end
