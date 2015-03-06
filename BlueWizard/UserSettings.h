#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

@property (nonatomic, strong) NSNumber *preEmphasisAlpha;
@property (nonatomic, strong) NSNumber *sampleRate;
@property (nonatomic, strong) NSNumber *exportSampleRate;
@property (nonatomic, strong) NSNumber *frameRate;
@property (nonatomic, strong) NSNumber *maxRMSIndex;

+(instancetype)sharedInstance;

@end
