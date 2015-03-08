#import <Cocoa/Cocoa.h>

@class PlayheadView;

@interface ViewController : NSViewController

@property (weak) IBOutlet NSScrollView *inputSampleView;
@property (weak) IBOutlet PlayheadView *playheadView;

@end

