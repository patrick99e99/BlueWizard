#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

@property (nonatomic, strong) NSNumber *preEmphasisAlpha;
@property (nonatomic, strong) NSNumber *sampleRate;
@property (nonatomic, strong) NSNumber *exportSampleRate;
@property (nonatomic, strong) NSNumber *frameRate;
@property (nonatomic, strong) NSNumber *maxRMSIndex;
@property (nonatomic, strong) NSNumber *maxPitchInHZ;
@property (nonatomic, strong) NSNumber *minPitchInHZ;
@property (nonatomic, strong) NSNumber *subMultipleThreshold;
@property (nonatomic) NSUInteger pitchValue;

+(instancetype)sharedInstance;

@end
