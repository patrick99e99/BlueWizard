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
        _preEmphasisAlpha = @-0.93750f;
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

-(NSNumber *)exportSampleRate {
    if (!_exportSampleRate) {
        _exportSampleRate = @48000;
    }
    return _exportSampleRate;
}

-(NSNumber *)maxPitchInHZ {
    if (!_maxPitchInHZ) {
        _maxPitchInHZ = @500;
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

-(NSNumber *)pitchOffset {
    if (!_pitchOffset) {
        _pitchOffset = @0;
    }
    return _pitchOffset;
}

-(NSNumber *)unvoicedThreshold {
    if (!_unvoicedThreshold) {
        _unvoicedThreshold = @0.3f;
    }
    return _unvoicedThreshold;
}

-(NSNumber *)rmsLimit {
    if (!_rmsLimit) {
        _rmsLimit = @14;
    }
    return _rmsLimit;
}

-(NSNumber *)unvoicedRMSLimit {
    if (!_unvoicedRMSLimit) {
        _unvoicedRMSLimit = @14;
    }
    return _unvoicedRMSLimit;
}

-(NSNumber *)lowPassCutoff {
    if (!_lowPassCutoff) {
        _lowPassCutoff = @48000;
    }
    return _lowPassCutoff;
}

-(NSNumber *)highPassCutoff {
    if (!_highPassCutoff) {
        _highPassCutoff = @0;
    }
    return _highPassCutoff;
}

-(NSNumber *)speed {
    if (!_speed) {
        _speed = @1.0f;
    }
    return _speed;
}

-(NSNumber *)unvoicedMultiplier {
    if (!_unvoicedMultiplier) {
        _unvoicedMultiplier = @0.5f;
    }
    return _unvoicedMultiplier;
}

-(NSNumber *)gain {
    if (!_gain) {
        _gain = @1.0f;
    }
    return _gain;
}

-(NSNumber *)windowWidth {
    if (!_windowWidth) {
        _windowWidth = @2;
    }
    return _windowWidth;
}

@end
