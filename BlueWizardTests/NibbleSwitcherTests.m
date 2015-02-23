#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "NibbleSwitcher.h"

@interface NibbleSwitcherTests : XCTestCase

@end

@implementation NibbleSwitcherTests {
    NSArray *subject;
}

-(void)setUp {
    [super setUp];
    NSArray *hex = @[ @"90", @"4d", @"66", @"66", @"18", @"50", @"b4", @"5a", @"0a", @"a6", @"d5", @"5b", @"6b", @"e5", @"6a", @"54", @"71", @"8a", @"e5", @"c0" ];
    subject = [NibbleSwitcher process:hex];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testItSwitchesTheNibbles {
    NSArray *expected = @[@"09", @"d4", @"66", @"66", @"81", @"05", @"4b", @"a5", @"a0", @"6a", @"5d", @"b5", @"b6", @"5e", @"a6", @"45", @"17", @"a8", @"5e", @"0c" ];
    XCTAssertEqualObjects(subject, expected);
}

@end
