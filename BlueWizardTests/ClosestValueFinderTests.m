#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "ClosestValueFinder.h"
#import "CodingTable.h"

@interface ClosestValueFinderTests : XCTestCase

@end

@implementation ClosestValueFinderTests {
    NSNumber *subject;
    NSInteger subj;
}

-(void)setUp {
    [super setUp];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testItFindsTheClosestIndexGivenAnActualValueAndAListOfValues {
    NSUInteger size = 2;

    float floats[] = {1.0f, 2.0f};
    subj = [ClosestValueFinder indexFor:1.25f floats:floats size:size];
    XCTAssertEqual(subj, 0);

    subj = [ClosestValueFinder indexFor:1.75f floats:floats size:size];
    XCTAssertEqual(subj, 1);

    floats[0] = 5.0f;
    floats[1] = 6.0f;
    subj = [ClosestValueFinder indexFor:-1.0f floats:floats size:size];
    XCTAssertEqual(subj, 0);
    
    subj = [ClosestValueFinder indexFor:8.0f floats:floats size:size];
    XCTAssertEqual(subj, 1);
}

@end
