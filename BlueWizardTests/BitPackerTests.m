#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "BitPacker.h"
#import "CodingTable.h"

@interface BitPackerTests : XCTestCase

@end

@implementation BitPackerTests {
    NSArray *frameData;
    NSString *byteStream;
}

-(void)setUp {
    [super setUp];

    frameData = @[
                           @{ kParameterGain: @9,  kParameterRepeat: @0, kParameterPitch: @0, kParameterK1: @21, kParameterK2: @22, kParameterK3: @6, kParameterK4: @6 },
                           @{ kParameterGain: @6,  kParameterRepeat: @1, kParameterPitch: @0 },
                           @{ kParameterGain: @6,  kParameterRepeat: @1, kParameterPitch: @0 },
                           @{ kParameterGain: @13, kParameterRepeat: @0, kParameterPitch: @10, kParameterK1: @18, kParameterK2: @16, kParameterK3: @5, kParameterK4: @5, kParameterK5: @6, kParameterK6: @11, kParameterK7: @10, kParameterK8: @5, kParameterK9: @3, kParameterK10: @2 },
                           @{ kParameterGain: @13, kParameterRepeat: @1, kParameterPitch: @11 },
                           @{ kParameterGain: @13, kParameterRepeat: @0, kParameterPitch: @12, kParameterK1: @22, kParameterK2: @17, kParameterK3: @7, kParameterK4: @4, kParameterK5: @0, kParameterK6: @10, kParameterK7: @11, kParameterK8: @6, kParameterK9: @4, kParameterK10: @3 },
                           @{ kParameterGain: @0 }
                           ];
    
    byteStream = @"09,d4,66,66,81,05,4b,a5,a0,6a,5d,b5,b6,5e,a6,45,17,a8,5e,0c";
    
    id classMock = OCMClassMock([CodingTable class]);
    NSArray *bits = @[ @4, @1, @5, @5, @5, @4, @4, @4, @4, @4, @3, @3, @3 ];
    OCMStub([classMock bits]).andReturn(bits);
}

-(void)tearDown {
    [super tearDown];
}

-(void)testItPacksFrameDataIntoAByteStream {
    XCTAssertEqualObjects([BitPacker pack:frameData], byteStream);
}

-(void)testItUnpacksAByteStreamIntoFrameData {
    XCTAssertEqualObjects([BitPacker unpack:byteStream options:nil], frameData);
}

@end
