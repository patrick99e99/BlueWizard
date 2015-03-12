#import <Cocoa/Cocoa.h>

@class PlayheadView, WaveformView;

@interface ViewController : NSViewController

@property (weak) IBOutlet PlayheadView *playheadView;
@property (weak) IBOutlet WaveformView *inputWaveformView;
@property (weak) IBOutlet WaveformView *processedWaveformView;

@property (weak) IBOutlet NSTextField *minFrequencyTextfield;
@property (weak) IBOutlet NSTextField *maxFrequencyTextfield;
@property (weak) IBOutlet NSTextField *submultipleThresholdTextfield;
@property (weak) IBOutlet NSTextField *pitchValueTextfield;
@property (weak) IBOutlet NSTextField *unvoicedThresholdTextfield;

@property (weak) IBOutlet NSTextField *sampleRateTextfield;
@property (weak) IBOutlet NSTextField *frameRateTextfield;
@property (weak) IBOutlet NSTextField *preEmphasisAlphaTextfield;
@property (weak) IBOutlet NSTextField *rmsLimitTextfield;

@property (weak) IBOutlet NSButton *overridePitchButton;
@property (weak) IBOutlet NSButton *preEmphasisButton;
@property (weak) IBOutlet NSButton *normalizeRMSButton;
@property (unsafe_unretained) IBOutlet NSTextView *byteStreamTextView;

@end

