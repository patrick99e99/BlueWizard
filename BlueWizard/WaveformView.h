#import <Cocoa/Cocoa.h>
@class Buffer;

@interface WaveformView : NSScrollView
@property (nonatomic, strong) Buffer *buffer;
@end
