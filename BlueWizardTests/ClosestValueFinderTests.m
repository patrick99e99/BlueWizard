#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "ClosestValueFinder.h"

@interface ClosestValueFinderTests : XCTestCase

@end

@implementation ClosestValueFinderTests {
    NSNumber *subject;
}

-(void)setUp {
    [super setUp];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testItFindsTheClosestIndexGivenAnActualValueAndAListOfValues {
    subject = [ClosestValueFinder indexOrTranslatedValueFor:@1.25f values:@[@1, @2] translate:NO];
    XCTAssertEqualObjects(subject, @0);
    
    subject = [ClosestValueFinder indexOrTranslatedValueFor:@1.75f values:@[@1, @2] translate:NO];
    XCTAssertEqualObjects(subject, @1);

    subject = [ClosestValueFinder indexOrTranslatedValueFor:@-1 values:@[@5, @6] translate:NO];
    XCTAssertEqualObjects(subject, @0);

    subject = [ClosestValueFinder indexOrTranslatedValueFor:@8 values:@[@5, @6] translate:NO];
    XCTAssertEqualObjects(subject, @1);
}

-(void)testItReturnsTheTranslation {
    subject = [ClosestValueFinder indexOrTranslatedValueFor:@50 values:@[@100, @200] translate:YES];
    XCTAssertEqualObjects(subject, @100);

    subject = [ClosestValueFinder indexOrTranslatedValueFor:@250 values:@[@100, @200] translate:YES];
    XCTAssertEqualObjects(subject, @200);
}

@end
