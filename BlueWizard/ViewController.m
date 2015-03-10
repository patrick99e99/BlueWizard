#import "ViewController.h"
#import "UserSettings.h"

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

# pragma mark - Actions

- (IBAction)stopWasPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopWasPressed" object:nil];
}

- (IBAction)playWasPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playWasPressed" object:self.playheadView];
}
- (IBAction)PitchSliderChanged:(id)sender {
    NSSlider *slider = sender;
    NSUInteger pitchValue = [slider intValue];
    self.pitchLabel.stringValue = (pitchValue == 65) ? @"auto" : [NSString stringWithFormat:@"%i", (int)pitchValue];
    [[UserSettings sharedInstance] setPitchValue:pitchValue];
}

@end