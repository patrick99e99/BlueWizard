#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "BitPacker.h"
#import "CodingTable.h"
#import "FrameData.h"
#import "Reflector.h"
#import "UserSettings.h"

@interface BitPackerTests : XCTestCase

@end

@implementation BitPackerTests {
    NSArray *frames;
    NSString *byteStream;
    NSString *byteStreamWithPrefix;
    Reflector *reflector1;
    Reflector *reflector2;
    Reflector *reflector3;
    Reflector *reflector4;
    Reflector *reflector5;
    Reflector *reflector6;
    Reflector *reflector7;
    Reflector *reflector8;
    Reflector *reflector9;
    Reflector *reflector10;
}

-(void)setUp {
    [super setUp];
    
    reflector1  = [[Reflector alloc] init];
    reflector2  = [[Reflector alloc] init];
    reflector3  = [[Reflector alloc] init];
    reflector4  = [[Reflector alloc] init];
    reflector5  = [[Reflector alloc] init];
    reflector6  = [[Reflector alloc] init];
    reflector7  = [[Reflector alloc] init];
    reflector8  = [[Reflector alloc] init];
    reflector9  = [[Reflector alloc] init];
    reflector10 = [[Reflector alloc] init];

    frames = @[
               [self frameDataFor:reflector1 gain:@9 repeat:@NO pitch:@0 k1:@21 k2:@22 k3:@6 k4:@6 k5:nil k6:nil k7:nil k8:nil k9:nil k10:nil],
               [self frameDataFor:reflector2 gain:@6 repeat:@YES pitch:@0 k1:nil k2:nil k3:nil k4:nil k5:nil k6:nil k7:nil k8:nil k9:nil k10:nil],
               [self frameDataFor:reflector3 gain:@6 repeat:@YES pitch:@0 k1:nil k2:nil k3:nil k4:nil k5:nil k6:nil k7:nil k8:nil k9:nil k10:nil],
               [self frameDataFor:reflector4 gain:@13 repeat:@NO pitch:@10 k1:@18 k2:@16 k3:@5 k4:@5 k5:@6 k6:@11 k7:@10 k8:@5 k9:@3 k10:@2],
               [self frameDataFor:reflector5 gain:@13 repeat:@YES pitch:@11 k1:nil k2:nil k3:nil k4:nil k5:nil k6:nil k7:nil k8:nil k9:nil k10:nil],
               [self frameDataFor:reflector6 gain:@13 repeat:@NO pitch:@12 k1:@22 k2:@17 k3:@7 k4:@4 k5:@0 k6:@10 k7:@11 k8:@6 k9:@4 k10:@3],
               [self frameDataFor:reflector7 gain:@0 repeat:nil pitch:nil k1:nil k2:nil k3:nil k4:nil k5:nil k6:nil k7:nil k8:nil k9:nil k10:nil],
    ];
    
    byteStream = @"09,d4,66,66,81,05,4b,a5,a0,6a,5d,b5,b6,5e,a6,45,17,a8,5e,0c";
    byteStreamWithPrefix = @"0x09,0xd4,0x66,0x66,0x81,0x05,0x4b,0xa5,0xa0,0x6a,0x5d,0xb5,0xb6,0x5e,0xa6,0x45,0x17,0xa8,0x5e,0x0c";
    
    int *bits = [CodingTable bits];
    bits[2] = 5;
}

-(void)tearDown {
    [super tearDown];
    [[UserSettings sharedInstance] setIncludeHexPrefix:NO];
}

-(FrameData *)frameDataFor:(Reflector *)reflector
                      gain:(NSNumber *)gain
                    repeat:(NSNumber *)repeat
                     pitch:(NSNumber *)pitch
                        k1:(NSNumber *)k1
                        k2:(NSNumber *)k2
                        k3:(NSNumber *)k3
                        k4:(NSNumber *)k4
                        k5:(NSNumber *)k5
                        k6:(NSNumber *)k6
                        k7:(NSNumber *)k7
                        k8:(NSNumber *)k8
                        k9:(NSNumber *)k9
                       k10:(NSNumber *)k10 {
    FrameData *frameData = [[FrameData alloc] initWithReflector:reflector pitch:0 repeat:NO];
    [frameData setParameter:kParameterGain value:gain];
    [frameData setParameter:kParameterRepeat value:repeat];
    [frameData setParameter:kParameterPitch value:pitch];
    [frameData setParameter:kParameterK1 value:k1];
    [frameData setParameter:kParameterK2 value:k2];
    [frameData setParameter:kParameterK3 value:k3];
    [frameData setParameter:kParameterK4 value:k4];
    [frameData setParameter:kParameterK5 value:k5];
    [frameData setParameter:kParameterK6 value:k6];
    [frameData setParameter:kParameterK7 value:k7];
    [frameData setParameter:kParameterK8 value:k8];
    [frameData setParameter:kParameterK9 value:k9];
    [frameData setParameter:kParameterK10 value:k10];

    return frameData;
}

-(void)testItPacksFrameDataIntoAByteStream {
    XCTAssertEqualObjects([BitPacker pack:frames], byteStream);
    [[UserSettings sharedInstance] setIncludeHexPrefix:YES];
    XCTAssertEqualObjects([BitPacker pack:frames], byteStreamWithPrefix);
}

-(void)testItUnpacksAByteStreamIntoFrameData {
    NSArray *frameData = [[BitPacker unpack:byteStream] valueForKey:@"parameters"];
    NSDictionary *parameters;
    
    parameters = frameData[0];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @9);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @NO);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @0);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK1], @21);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK2], @22);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK3], @6);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK4], @6);
    XCTAssertNil([parameters objectForKey:kParameterK5]);
    XCTAssertNil([parameters objectForKey:kParameterK6]);
    XCTAssertNil([parameters objectForKey:kParameterK7]);
    XCTAssertNil([parameters objectForKey:kParameterK8]);
    XCTAssertNil([parameters objectForKey:kParameterK9]);
    XCTAssertNil([parameters objectForKey:kParameterK10]);
    
    parameters = frameData[1];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @6);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @YES);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @0);
    XCTAssertNil([parameters objectForKey:kParameterK1]);
    XCTAssertNil([parameters objectForKey:kParameterK2]);
    XCTAssertNil([parameters objectForKey:kParameterK3]);
    XCTAssertNil([parameters objectForKey:kParameterK4]);
    XCTAssertNil([parameters objectForKey:kParameterK5]);
    XCTAssertNil([parameters objectForKey:kParameterK6]);
    XCTAssertNil([parameters objectForKey:kParameterK7]);
    XCTAssertNil([parameters objectForKey:kParameterK8]);
    XCTAssertNil([parameters objectForKey:kParameterK9]);
    XCTAssertNil([parameters objectForKey:kParameterK10]);

    parameters = frameData[2];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @6);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @YES);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @0);
    XCTAssertNil([parameters objectForKey:kParameterK1]);
    XCTAssertNil([parameters objectForKey:kParameterK2]);
    XCTAssertNil([parameters objectForKey:kParameterK3]);
    XCTAssertNil([parameters objectForKey:kParameterK4]);
    XCTAssertNil([parameters objectForKey:kParameterK5]);
    XCTAssertNil([parameters objectForKey:kParameterK6]);
    XCTAssertNil([parameters objectForKey:kParameterK7]);
    XCTAssertNil([parameters objectForKey:kParameterK8]);
    XCTAssertNil([parameters objectForKey:kParameterK9]);
    XCTAssertNil([parameters objectForKey:kParameterK10]);
    
    parameters = frameData[3];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @13);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @NO);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @10);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK1], @18);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK2], @16);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK3], @5);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK4], @5);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK5], @6);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK6], @11);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK7], @10);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK8], @5);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK9], @3);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK10], @2);
    
    parameters = frameData[4];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @13);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @YES);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @11);
    XCTAssertNil([parameters objectForKey:kParameterK1]);
    XCTAssertNil([parameters objectForKey:kParameterK2]);
    XCTAssertNil([parameters objectForKey:kParameterK3]);
    XCTAssertNil([parameters objectForKey:kParameterK4]);
    XCTAssertNil([parameters objectForKey:kParameterK5]);
    XCTAssertNil([parameters objectForKey:kParameterK6]);
    XCTAssertNil([parameters objectForKey:kParameterK7]);
    XCTAssertNil([parameters objectForKey:kParameterK8]);
    XCTAssertNil([parameters objectForKey:kParameterK9]);
    XCTAssertNil([parameters objectForKey:kParameterK10]);
    
    parameters = frameData[5];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @13);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @NO);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @12);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK1], @22);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK2], @17);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK3], @7);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK4], @4);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK5], @0);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK6], @10);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK7], @11);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK8], @6);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK9], @4);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK10], @3);
    
    parameters = frameData[6];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @0);
    XCTAssertNil([parameters objectForKey:kParameterRepeat]);
    XCTAssertNil([parameters objectForKey:kParameterPitch]);
    XCTAssertNil([parameters objectForKey:kParameterK1]);
    XCTAssertNil([parameters objectForKey:kParameterK2]);
    XCTAssertNil([parameters objectForKey:kParameterK3]);
    XCTAssertNil([parameters objectForKey:kParameterK4]);
    XCTAssertNil([parameters objectForKey:kParameterK5]);
    XCTAssertNil([parameters objectForKey:kParameterK6]);
    XCTAssertNil([parameters objectForKey:kParameterK7]);
    XCTAssertNil([parameters objectForKey:kParameterK8]);
    XCTAssertNil([parameters objectForKey:kParameterK9]);
    XCTAssertNil([parameters objectForKey:kParameterK10]);
}

-(void)testItUnpacksAByteStreamWithHexPrefixesIntoFrameData {
    NSArray *frameData = [[BitPacker unpack:byteStreamWithPrefix] valueForKey:@"parameters"];
    NSDictionary *parameters;
    
    parameters = frameData[0];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @9);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @NO);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @0);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK1], @21);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK2], @22);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK3], @6);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK4], @6);
    XCTAssertNil([parameters objectForKey:kParameterK5]);
    XCTAssertNil([parameters objectForKey:kParameterK6]);
    XCTAssertNil([parameters objectForKey:kParameterK7]);
    XCTAssertNil([parameters objectForKey:kParameterK8]);
    XCTAssertNil([parameters objectForKey:kParameterK9]);
    XCTAssertNil([parameters objectForKey:kParameterK10]);
    
    parameters = frameData[1];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @6);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @YES);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @0);
    XCTAssertNil([parameters objectForKey:kParameterK1]);
    XCTAssertNil([parameters objectForKey:kParameterK2]);
    XCTAssertNil([parameters objectForKey:kParameterK3]);
    XCTAssertNil([parameters objectForKey:kParameterK4]);
    XCTAssertNil([parameters objectForKey:kParameterK5]);
    XCTAssertNil([parameters objectForKey:kParameterK6]);
    XCTAssertNil([parameters objectForKey:kParameterK7]);
    XCTAssertNil([parameters objectForKey:kParameterK8]);
    XCTAssertNil([parameters objectForKey:kParameterK9]);
    XCTAssertNil([parameters objectForKey:kParameterK10]);
    
    parameters = frameData[2];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @6);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @YES);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @0);
    XCTAssertNil([parameters objectForKey:kParameterK1]);
    XCTAssertNil([parameters objectForKey:kParameterK2]);
    XCTAssertNil([parameters objectForKey:kParameterK3]);
    XCTAssertNil([parameters objectForKey:kParameterK4]);
    XCTAssertNil([parameters objectForKey:kParameterK5]);
    XCTAssertNil([parameters objectForKey:kParameterK6]);
    XCTAssertNil([parameters objectForKey:kParameterK7]);
    XCTAssertNil([parameters objectForKey:kParameterK8]);
    XCTAssertNil([parameters objectForKey:kParameterK9]);
    XCTAssertNil([parameters objectForKey:kParameterK10]);
    
    parameters = frameData[3];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @13);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @NO);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @10);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK1], @18);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK2], @16);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK3], @5);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK4], @5);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK5], @6);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK6], @11);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK7], @10);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK8], @5);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK9], @3);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK10], @2);
    
    parameters = frameData[4];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @13);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @YES);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @11);
    XCTAssertNil([parameters objectForKey:kParameterK1]);
    XCTAssertNil([parameters objectForKey:kParameterK2]);
    XCTAssertNil([parameters objectForKey:kParameterK3]);
    XCTAssertNil([parameters objectForKey:kParameterK4]);
    XCTAssertNil([parameters objectForKey:kParameterK5]);
    XCTAssertNil([parameters objectForKey:kParameterK6]);
    XCTAssertNil([parameters objectForKey:kParameterK7]);
    XCTAssertNil([parameters objectForKey:kParameterK8]);
    XCTAssertNil([parameters objectForKey:kParameterK9]);
    XCTAssertNil([parameters objectForKey:kParameterK10]);
    
    parameters = frameData[5];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @13);
    XCTAssertEqualObjects([parameters objectForKey:kParameterRepeat], @NO);
    XCTAssertEqualObjects([parameters objectForKey:kParameterPitch], @12);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK1], @22);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK2], @17);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK3], @7);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK4], @4);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK5], @0);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK6], @10);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK7], @11);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK8], @6);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK9], @4);
    XCTAssertEqualObjects([parameters objectForKey:kParameterK10], @3);
    
    parameters = frameData[6];
    
    XCTAssertEqualObjects([parameters objectForKey:kParameterGain], @0);
    XCTAssertNil([parameters objectForKey:kParameterRepeat]);
    XCTAssertNil([parameters objectForKey:kParameterPitch]);
    XCTAssertNil([parameters objectForKey:kParameterK1]);
    XCTAssertNil([parameters objectForKey:kParameterK2]);
    XCTAssertNil([parameters objectForKey:kParameterK3]);
    XCTAssertNil([parameters objectForKey:kParameterK4]);
    XCTAssertNil([parameters objectForKey:kParameterK5]);
    XCTAssertNil([parameters objectForKey:kParameterK6]);
    XCTAssertNil([parameters objectForKey:kParameterK7]);
    XCTAssertNil([parameters objectForKey:kParameterK8]);
    XCTAssertNil([parameters objectForKey:kParameterK9]);
    XCTAssertNil([parameters objectForKey:kParameterK10]);
}

@end
