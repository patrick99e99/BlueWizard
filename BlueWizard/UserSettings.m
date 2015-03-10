#import "UserSettings.h"

@implementation UserSettings

+(instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{ sharedInstance = [[self alloc] init]; });
    
    return sharedInstance;
}

-(instancetype)init {
    if (self = [super init]) {
        self.pitchValue = 65;
    }
    return self;
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

-(NSNumber *)maxPitchInHZ {
    if (!_maxPitchInHZ) {
        _maxPitchInHZ = @200;
    }
    return _maxPitchInHZ;
}


-(NSNumber *)minPitchInHZ {
    if (!_minPitchInHZ) {
        _minPitchInHZ = @50;
    }
    return _minPitchInHZ;
}

-(NSNumber *)subMultipleThreshold {
    if (!_subMultipleThreshold) {
        _subMultipleThreshold = @0.9;
    }
    return _subMultipleThreshold;
}

@end
