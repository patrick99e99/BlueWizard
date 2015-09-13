#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "FrameData.h"
#import "Reflector.h"
#import "CodingTable.h"

@interface Reflector (FrameDataTests)
-(instancetype)initWithKs:(double *)ks rms:(double)rms limitRMS:(BOOL)limitRMS;
@end

@interface FrameDataTests : XCTestCase

@end

@implementation FrameDataTests {
    FrameData *subject;
    Reflector *reflector;
}

-(void)setUp {
    [super setUp];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testItHasAllParameters {
    double ks[] = { 0.0f, 0.0f };
    reflector = [[Reflector alloc] initWithKs:ks rms:32 limitRMS:NO];

    subject = [[FrameData alloc] initWithReflector:reflector pitch:32 repeat:NO];
    NSArray *paramterKeys = [[subject parameters] allKeys];
    XCTAssertTrue([paramterKeys containsObject:kParameterGain]);
    XCTAssertTrue([paramterKeys containsObject:kParameterRepeat]);
    XCTAssertTrue([paramterKeys containsObject:kParameterPitch]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK1]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK2]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK3]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK4]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK5]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK6]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK7]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK8]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK9]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK10]);
}

-(void)testItHasUnvoicedParameterWhenK1IsLarge {
    double ks[] = { 0.1, 5.0f };
    
    reflector = [[Reflector alloc] initWithKs:ks rms:32 limitRMS:NO];
    XCTAssertTrue([reflector isUnvoiced]);
    
    subject = [[FrameData alloc] initWithReflector:reflector pitch:32 repeat:NO];
    NSArray *paramterKeys = [[subject parameters] allKeys];
    XCTAssertTrue([paramterKeys containsObject:kParameterGain]);
    XCTAssertTrue([paramterKeys containsObject:kParameterRepeat]);
    XCTAssertTrue([paramterKeys containsObject:kParameterPitch]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK1]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK2]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK3]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK4]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK5]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK6]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK7]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK8]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK9]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK10]);
}

-(void)testItHasUnvoicedParameterWhenPitchIsZero {
    double ks[] = { 0.1f, 0.1f };
    reflector = [[Reflector alloc] initWithKs:ks rms:32 limitRMS:NO];
    
    subject = [[FrameData alloc] initWithReflector:reflector pitch:0 repeat:NO];
    NSArray *paramterKeys = [[subject parameters] allKeys];
    XCTAssertTrue([paramterKeys containsObject:kParameterGain]);
    XCTAssertTrue([paramterKeys containsObject:kParameterRepeat]);
    XCTAssertTrue([paramterKeys containsObject:kParameterPitch]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK1]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK2]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK3]);
    XCTAssertTrue([paramterKeys containsObject:kParameterK4]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK5]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK6]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK7]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK8]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK9]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK10]);
}

-(void)testItHasGainOnlyParametersWhenGainIsZero {
    double ks[] = { 0.0f, 0.0f };
    reflector = [[Reflector alloc] initWithKs:ks rms:0 limitRMS:NO];
    
    subject = [[FrameData alloc] initWithReflector:reflector pitch:0 repeat:NO];
    NSArray *paramterKeys = [[subject parameters] allKeys];
    XCTAssertTrue([paramterKeys containsObject:kParameterGain]);
    XCTAssertFalse([paramterKeys containsObject:kParameterRepeat]);
    XCTAssertFalse([paramterKeys containsObject:kParameterPitch]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK1]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK2]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK3]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK4]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK5]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK6]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK7]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK8]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK9]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK10]);
}

-(void)testItHasRepeatParameters {
    double ks[] = { 0.0f, 0.0f };
    reflector = [[Reflector alloc] initWithKs:ks rms:32 limitRMS:NO];
    
    subject = [[FrameData alloc] initWithReflector:reflector pitch:32 repeat:YES];
    NSArray *paramterKeys = [[subject parameters] allKeys];
    XCTAssertTrue([paramterKeys containsObject:kParameterGain]);
    XCTAssertTrue([paramterKeys containsObject:kParameterRepeat]);
    XCTAssertTrue([paramterKeys containsObject:kParameterPitch]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK1]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK2]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK3]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK4]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK5]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK6]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK7]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK8]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK9]);
    XCTAssertFalse([paramterKeys containsObject:kParameterK10]);
}

-(void)testItHasTranslatedParamteres {
    double ks[] = { 0.0f, 0.0f };
    reflector = [[Reflector alloc] initWithKs:ks rms:32 limitRMS:NO];
    
    subject = [[FrameData alloc] initWithReflector:reflector pitch:32 repeat:YES];
    NSNumber *gain = [[subject translatedParameters] objectForKey:kParameterGain];
    XCTAssertEqualObjects(gain, @52.0f);
}

@end
