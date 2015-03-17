#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "NibbleBitReverser.h"

@interface NibbleBitReverserTests : XCTestCase

@end

@implementation NibbleBitReverserTests {
    NSArray *subject;
}

-(void)setUp {
    [super setUp];
    NSArray *hex =  @[ @"9", @"2b", @"66", @"66", @"81", @"a0", @"d2", @"a5", @"05", @"56", @"ba", @"ad", @"6d", @"7a", @"65", @"a2", @"e8", @"15", @"7a", @"3" ];
    subject = [NibbleBitReverser process:hex];
}

-(void)tearDown {
    [super tearDown];
}

- (void)testItReversesTheBitsInEachByte {
    NSArray *expected = @[ @"90", @"4d", @"66", @"66", @"18", @"50", @"b4", @"5a", @"0a", @"a6", @"d5", @"5b", @"6b", @"e5", @"6a", @"54", @"71", @"8a", @"e5", @"c0" ];
    XCTAssertEqualObjects(subject, expected);
}

@end
