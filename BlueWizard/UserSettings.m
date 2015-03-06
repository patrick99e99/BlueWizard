#import "UserSettings.h"

@implementation UserSettings

+(instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{ sharedInstance = [[self alloc] init]; });
    
    return sharedInstance;
}

-(NSNumber *)preEmphasisAlpha {
    if (!_preEmphasisAlpha) {
        _preEmphasisAlpha = @0.93750f;
    }
    return _preEmphasisAlpha;
}

-(NSNumber *)sampleRate {
    if (!_sampleRate) {
        _sampleRate = @8000;
    }
    return _sampleRate;
}

-(NSNumber *)frameRate {
    if (!_frameRate) {
        _frameRate = @25.0f;
    }
    return _frameRate;
}

-(NSNumber *)maxRMSIndex {
    if (!_maxRMSIndex) {
        _maxRMSIndex = @14;
    }
    return _maxRMSIndex;
}

-(NSNumber *)exportSampleRate {
    if (!_exportSampleRate) {
        _exportSampleRate = @48000;
    }
    return _exportSampleRate;
}

@end
