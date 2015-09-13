#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "Reflector.h"
#import "CodingTable.h"

@interface Reflector (ReflectorTests)
@property (nonatomic, getter=shouldLimitRMS) BOOL limitRMS;
@end

@interface ReflectorTests : XCTestCase

@end

@implementation ReflectorTests {
    Reflector *subject;
    double *samples;
}

-(void)setUp {
    subject = [[Reflector alloc] init];
    [super setUp];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testItDoesNotAllowStopFramesToGetGenerated {
    subject.rms = [CodingTable rms][15];
    XCTAssertEqual(subject.rms, [CodingTable rms][15]);
    subject.limitRMS = YES;
    XCTAssertEqual(subject.rms, [CodingTable rms][14]);
}

@end
