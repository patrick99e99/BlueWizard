#import "ViewController.h"
#import "UserSettings.h"
#import "NotificationNames.h"
#import "WaveformView.h"


@implementation ViewController

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInputWaveformView:) name:inputSignalReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProcessedWaveformView:) name:bufferGenerated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateByteStreamView:) name:byteStreamGenerated object:nil];

    [super viewDidLoad];
    [self updateInputsToMatchUserSettings];
}

-(void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [self updateInputsToMatchUserSettings];
}

-(void)updateInputsToMatchUserSettings {
    self.minFrequencyTextfield.stringValue         = [[[self userSettings] minPitchInHZ] stringValue];
    self.maxFrequencyTextfield.stringValue         = [[[self userSettings] maxPitchInHZ] stringValue];
    self.submultipleThresholdTextfield.stringValue = [[[self userSettings] subMultipleThreshold] stringValue];
    self.pitchValueTextfield.stringValue           = [[[self userSettings] pitchValue] stringValue];
    self.unvoicedThresholdTextfield.stringValue    = [[[self userSettings] unvoicedThreshold] stringValue];
    self.sampleRateTextfield.stringValue           = [[[self userSettings] sampleRate] stringValue];
    self.frameRateTextfield.stringValue            = [[[self userSettings] frameRate] stringValue];
    self.preEmphasisAlphaTextfield.stringValue     = [[[self userSettings] preEmphasisAlpha] stringValue];
    self.rmsLimitTextfield.stringValue             = [[[self userSettings] rmsLimit] stringValue];
    
    self.overridePitchButton.state  = [[self userSettings] overridePitch];
    self.preEmphasisButton.state    = [[self userSettings] preEmphasis];
    self.normalizeRMSButton.state   = [[self userSettings] normalizeRMS];
    
    [self overridePitchToggled:self.overridePitchButton];
    [self preEmphasisToggled:self.preEmphasisButton];
    [self normalizeRMSToggled:self.normalizeRMSButton];
}

-(void)updateInputWaveformView:(NSNotification *)notification {
    self.inputWaveformView.buffer = (Buffer *)notification.object;
}

-(void)updateProcessedWaveformView:(NSNotification *)notification {
    self.processedWaveformView.buffer = (Buffer *)notification.object;
}

-(void)updateByteStreamView:(NSNotification *)notification {
    self.byteStreamTextView.string = (NSString *)notification.object;
}

# pragma mark - Actions

-(IBAction)stopOriginalWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:stopOriginalWasClicked object:nil];
}

-(IBAction)playOriginalWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:playOriginalWasClicked object:self.playheadView];
}

-(IBAction)stopProcessedWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:stopProcessedWasClicked object:nil];
}

-(IBAction)playProcessedWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:playProcessedWasClicked object:self.playheadView];
}

-(IBAction)minFrequencyChanged:(NSTextField *)sender {
    [[self userSettings] setMinPitchInHZ:[self numberFromStrong:[sender stringValue]]];
}

-(IBAction)maxFrequencyChanged:(NSTextField *)sender {
    [[self userSettings] setMaxPitchInHZ:[self numberFromStrong:[sender stringValue]]];
}

-(IBAction)submultipleThresholdChanged:(NSTextField *)sender {
    [[self userSettings] setSubMultipleThreshold:[self numberFromStrong:[sender stringValue]]];
}

-(IBAction)pitchValueChanged:(NSTextField *)sender {
    [[self userSettings] setPitchValue:[self numberFromStrong:[sender stringValue]]];
}

-(IBAction)overridePitchToggled:(NSButton *)sender {
    BOOL state = [sender state];

    [self.minFrequencyTextfield setEnabled:!state];
    [self.maxFrequencyTextfield setEnabled:!state];
    [self.pitchValueTextfield setEnabled:state];

    [[self userSettings] setOverridePitch:state];
}

- (IBAction)unvoicedThresholdChanged:(NSTextField *)sender {
    [[self userSettings] setUnvoicedThreshold:[self numberFromStrong:[sender stringValue]]];
}

- (IBAction)sampleRateChanged:(NSTextField *)sender {
    [[self userSettings] setSampleRate:[self numberFromStrong:[sender stringValue]]];
}

-(IBAction)frameRateChanged:(NSTextField *)sender {
    [[self userSettings] setFrameRate:[self numberFromStrong:[sender stringValue]]];
}

- (IBAction)preEmphasisAlphaChanged:(NSTextField *)sender {
    [[self userSettings] setPreEmphasisAlpha:[self numberFromStrong:[sender stringValue]]];
}

- (IBAction)rmsLimitChanged:(NSTextField *)sender {
    [[self userSettings] setRmsLimit:[self numberFromStrong:[sender stringValue]]];
}

- (IBAction)preEmphasisToggled:(NSButton *)sender {
    BOOL state = [sender state];
    
    [self.preEmphasisAlphaTextfield setEnabled:state];
    [[self userSettings] setPreEmphasis:state];
}

- (IBAction)normalizeRMSToggled:(NSButton *)sender {
    BOOL state = [sender state];
    
    [self.rmsLimitTextfield setEnabled:state];
    [[self userSettings] setNormalizeRMS:state];
}

- (IBAction)processInputSignalClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:processInputSignalWasClicked object:nil];
}

-(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

-(NSNumber *)numberFromStrong:(NSString *)string {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter numberFromString:string];
}

@end