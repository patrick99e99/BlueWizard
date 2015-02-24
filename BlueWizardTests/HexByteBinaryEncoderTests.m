#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "HexByteBinaryEncoder.h"

@interface HexByteBinaryEncoderTests : XCTestCase

@end

@implementation HexByteBinaryEncoderTests {
    NSArray *subject;
}

-(void)setUp {
    [super setUp];
    NSArray *hex = @[ @"90", @"2b", @"66", @"66", @"81", @"a0", @"d2", @"a5", @"05", @"56", @"ba", @"ad", @"6d", @"7a", @"65", @"a2", @"e8", @"15", @"7a", @"30" ];
    subject = [HexByteBinaryEncoder process:hex];
}

-(void)tearDown {
    [super tearDown];
}

- (void)testItConvertsHexIntoBinaryNibbles {
    NSArray *expected = @[ @"1001", @"0000", @"0010", @"1011", @"0110", @"0110", @"0110", @"0110", @"1000", @"0001", @"1010", @"0000", @"1101", @"0010", @"1010", @"0101", @"0000", @"0101", @"0101", @"0110", @"1011", @"1010", @"1010", @"1101", @"0110", @"1101", @"0111", @"1010", @"0110", @"0101", @"1010", @"0010", @"1110", @"1000", @"0001", @"0101", @"0111", @"1010", @"0011", @"0000" ];
    XCTAssertEqualObjects(subject, expected);
}

@end
