#import <Cocoa/Cocoa.h>

@class Sampler, WaveformView;
@interface PlayheadView : NSImageView

@property (nonatomic) NSUInteger position;
@property (nonatomic, weak) Sampler *sampler;
@property (nonatomic, weak) WaveformView *waveformView;

-(float)containerWidth;

@end
