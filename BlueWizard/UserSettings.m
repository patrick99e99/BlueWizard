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

-(NSNumber *)pitchValue {
    if (!_pitchValue) {
        _pitchValue = @0;
    }
    return _pitchValue;
}

-(NSNumber *)unvoicedThreshold {
    if (!_unvoicedThreshold) {
        _unvoicedThreshold = @0.05f;
    }
    return _unvoicedThreshold;
}

-(NSNumber *)rmsLimit {
    if (!_rmsLimit) {
        _rmsLimit = @14;
    }
    return _rmsLimit;
}


@end
