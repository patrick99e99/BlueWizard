#import <Cocoa/Cocoa.h>

@class Sampler;
@interface PlayheadView : NSBox

@property (nonatomic) NSUInteger position;
@property (nonatomic, weak) Sampler *sampler;

-(float)containerWidth;

@end
