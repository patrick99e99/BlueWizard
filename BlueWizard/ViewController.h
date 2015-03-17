#import <Cocoa/Cocoa.h>

@class PlayheadView, WaveformView;

@interface ViewController : NSViewController <NSTextViewDelegate, NSTableViewDataSource, NSTableViewDelegate>

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
@property (weak) IBOutlet NSButton *excitationFilterOnlyButton;
@property (unsafe_unretained) IBOutlet NSTextView *byteStreamTextView;
@property (weak) IBOutlet NSTableView *frameDataTableView;
@property (weak) IBOutlet NSButton *translateParametersCheckbox;
@property (weak) IBOutlet NSProgressIndicator *spinner;

@end

