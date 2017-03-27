#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

@property (nonatomic, strong) NSNumber *preEmphasisAlpha;
@property (nonatomic, strong) NSNumber *sampleRate;
@property (nonatomic, strong) NSNumber *exportSampleRate;
@property (nonatomic, strong) NSNumber *frameRate;
@property (nonatomic, strong) NSNumber *maxPitchInHZ;
@property (nonatomic, strong) NSNumber *minPitchInHZ;
@property (nonatomic, strong) NSNumber *subMultipleThreshold;
@property (nonatomic, strong) NSNumber *unvoicedThreshold;
@property (nonatomic, strong) NSNumber *pitchValue;
@property (nonatomic, strong) NSNumber *pitchOffset;
@property (nonatomic, strong) NSNumber *rmsLimit;
@property (nonatomic, strong) NSNumber *unvoicedRMSLimit;
@property (nonatomic, strong) NSNumber *lowPassCutoff;
@property (nonatomic, strong) NSNumber *highPassCutoff;
@property (nonatomic, strong) NSNumber *speed;
@property (nonatomic, strong) NSNumber *windowWidth;
@property (nonatomic, strong) NSNumber *unvoicedMultiplier;
@property (nonatomic, strong) NSNumber *gain;
@property (nonatomic, strong) NSNumber *startSample;
@property (nonatomic, strong) NSNumber *endSample;

@property (nonatomic) BOOL overridePitch;
@property (nonatomic) BOOL preEmphasis;
@property (nonatomic) BOOL normalizeVoicedRMS;
@property (nonatomic) BOOL normalizeUnvoicedRMS;
@property (nonatomic) BOOL excitationFilterOnly;
@property (nonatomic) BOOL skipLeadingSilence;
@property (nonatomic) BOOL includeHexPrefix;
@property (nonatomic) BOOL includeExplicitStopFrame;

+(instancetype)sharedInstance;

@end
