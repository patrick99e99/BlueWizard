#import "ViewController.h"
#import "UserSettings.h"
#import "NotificationNames.h"
#import "WaveformView.h"
#import "CodingTable.h"
#import "FrameData.h"
#import "LargeWaveformViewController.h"
#import "AppDelegate.h"

static NSString * const kFrameDataTableViewIdentifier = @"parameter";
static NSString * const kFrameDataTableViewFrameKey = @"frame";

@interface ViewController ()
@property (nonatomic, strong) NSArray *frameData;
@property (nonatomic, strong) NSNumber *timestamp;
@property (nonatomic, strong) NSWindowController *waveformWindow;

@end

@implementation ViewController

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInputWaveformView:) name:inputSignalReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProcessedWaveformView:) name:bufferGenerated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateByteStreamView:) name:byteStreamGenerated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDataGenerated:) name:frameDataGenerated object:nil];

    [super viewDidLoad];
    [self updateInputsToMatchUserSettings];
}

-(void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [self updateInputsToMatchUserSettings];
}

- (IBAction)inspectWasClicked:(id)sender {
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    self.waveformWindow = [storyBoard instantiateControllerWithIdentifier:@"Waveform"];
    LargeWaveformViewController *viewController = (LargeWaveformViewController *)[[self.waveformWindow window] contentViewController];
    viewController.waveformView.buffer = self.processedWaveformView.buffer;
    [self.waveformWindow showWindow:self];
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
    self.lowPassCutoffTextField.stringValue        = [[[self userSettings] lowPassCutoff] stringValue];
    self.highPassCutoffTextField.stringValue       = [[[self userSettings] highPassCutoff] stringValue];
    self.windowWidthTextfield.stringValue          = [[[self userSettings] windowWidth] stringValue];
    
    self.overridePitchButton.state  = [[self userSettings] overridePitch];
    self.preEmphasisButton.state    = [[self userSettings] preEmphasis];
    self.normalizeRMSButton.state   = [[self userSettings] normalizeVoicedRMS];
    self.normalizeUnvoicedRMSButton.state = [[self userSettings] normalizeUnvoicedRMS];
    
    [self overridePitchToggled:self.overridePitchButton];
    [self preEmphasisToggled:self.preEmphasisButton];
    [self normalizeRMSToggled:self.normalizeRMSButton];
    [self normalizeUnvoicedRMSToggled:self.normalizeUnvoicedRMSButton];
}

-(void)updateInputWaveformView:(NSNotification *)notification {
    self.inputWaveformView.buffer = notification.object;
}

-(void)updateProcessedWaveformView:(NSNotification *)notification {
    self.processedWaveformView.buffer = notification.object;
    NSNumber *startSample = [[self userSettings] startSample];
    NSNumber *endSample   = [[self userSettings] endSample];
    if (!startSample || !endSample) return;
    self.startSample.stringValue = [startSample stringValue];
    self.endSample.stringValue   = [endSample stringValue];
}

-(void)updateByteStreamView:(NSNotification *)notification {
    [self.byteStreamTextView setTextColor:[NSColor blueColor]];

    self.byteStreamTextView.string = notification.object;
}

-(void)frameDataGenerated:(NSNotification *)notification {
    if (self.spinner.hidden) [self showSpinner];
    self.frameData = notification.object;
}

-(void)setFrameData:(NSArray *)frameData {
    _frameData = frameData;
    [self.frameDataTableView reloadData];
}

-(BOOL)hasInput {
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    return [appDelegate hasInput];
}

-(NSNumber *)limitedForRMSInput:(NSTextField *)textField {
    NSNumber *wrappedValue = [self numberFromString:[textField stringValue]];
    NSInteger value = [wrappedValue integerValue];
    if (value < 0) return @0;
    if (value > 14) return @14;
    return wrappedValue;
}

# pragma mark - Actions

-(IBAction)stopOriginalWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:stopOriginalWasClicked object:nil];
}

-(IBAction)playOriginalWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:playOriginalWasClicked object:@[self.inputPlayheadView, self.OutputPlayheadView]];
}

-(IBAction)stopProcessedWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:stopProcessedWasClicked object:nil];
}

-(IBAction)playProcessedWasClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:playProcessedWasClicked object:@[self.inputPlayheadView, self.OutputPlayheadView]];
}

-(IBAction)minFrequencyChanged:(NSTextField *)sender {
    [[self userSettings] setMinPitchInHZ:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

-(IBAction)maxFrequencyChanged:(NSTextField *)sender {
    [[self userSettings] setMaxPitchInHZ:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

-(IBAction)submultipleThresholdChanged:(NSTextField *)sender {
    [[self userSettings] setSubMultipleThreshold:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

-(IBAction)pitchValueChanged:(NSTextField *)sender {
    [[self userSettings] setPitchValue:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}   

-(IBAction)overridePitchToggled:(NSButton *)sender {
    BOOL state = [sender state];

    [self.minFrequencyTextfield setEnabled:!state];
    [self.maxFrequencyTextfield setEnabled:!state];
    [self.submultipleThresholdTextfield setEnabled:!state];
    [self.pitchValueTextfield setEnabled:state];
    [self.pitchOffsetTextField setEnabled:!state];

    [[self userSettings] setOverridePitch:state];
    [self notifySettingsChanged];
}

- (IBAction)unvoicedThresholdChanged:(NSTextField *)sender {
    [[self userSettings] setUnvoicedThreshold:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

- (IBAction)sampleRateChanged:(NSTextField *)sender {
    [[self userSettings] setSampleRate:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

-(IBAction)frameRateChanged:(NSTextField *)sender {
    [[self userSettings] setFrameRate:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

- (IBAction)preEmphasisAlphaChanged:(NSTextField *)sender {
    [[self userSettings] setPreEmphasisAlpha:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

- (IBAction)rmsLimitChanged:(NSTextField *)sender {
    NSNumber *limit = [self limitedForRMSInput:sender];
    [[self userSettings] setRmsLimit:limit];
    sender.stringValue = [limit stringValue];
    [self notifySettingsChanged];
}

- (IBAction)unvoicedRMSLimitChanged:(NSTextField *)sender {
    NSNumber *limit = [self limitedForRMSInput:sender];
    [[self userSettings] setUnvoicedRMSLimit:limit];
    sender.stringValue = [limit stringValue];
    [self notifySettingsChanged];
}

- (IBAction)pitchOffsetChanged:(NSTextField *)sender {
    [[self userSettings] setPitchOffset:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

- (IBAction)preEmphasisToggled:(NSButton *)sender {
    BOOL state = [sender state];
    
    [self.preEmphasisAlphaTextfield setEnabled:state];
    [[self userSettings] setPreEmphasis:state];
    [self notifySettingsChanged];
}

- (IBAction)normalizeRMSToggled:(NSButton *)sender {
    BOOL state = [sender state];
    
    [self.rmsLimitTextfield setEnabled:state];

    [[self userSettings] setNormalizeVoicedRMS:state];
    [self notifySettingsChanged];
}

- (IBAction)normalizeUnvoicedRMSToggled:(NSButton *)sender {
    BOOL state = [sender state];
    
    [self.unvoicedRMSLimitTextField setEnabled:state];
    
    [[self userSettings] setNormalizeUnvoicedRMS:state];
    [self notifySettingsChanged];
}

- (IBAction)excitationFilterOnlyToggled:(NSButton *)sender {
    [[self userSettings] setExcitationFilterOnly:[sender state]];
    [self notifySettingsChanged];
}

- (IBAction)skipLeadingSilenceToggled:(id)sender {
    BOOL state = [sender state];
    [[self userSettings] setSkipLeadingSilence:state];
    [self notifySettingsChanged];
}

- (IBAction)includeHexPrefixToggled:(id)sender {
    BOOL state = [sender state];
    [[self userSettings] setIncludeHexPrefix:state];
    [self notifySettingsChanged];
}

- (IBAction)includeExplicitStopFrameToggled:(id)sender {
    BOOL state = [sender state];
    [[self userSettings] setIncludeExplicitStopFrame:state];
    [self notifySettingsChanged];
}

- (IBAction)lowPassCutoffChanged:(NSTextField *)sender {
    [[self userSettings] setLowPassCutoff:[self numberFromString:[sender stringValue]]];
    [self notifySignalChanged];
    [self notifySettingsChanged];
}

- (IBAction)highPassCutoffChanged:(NSTextField *)sender {
    [[self userSettings] setHighPassCutoff:[self numberFromString:[sender stringValue]]];
    [self notifySignalChanged];
    [self notifySettingsChanged];
}

- (IBAction)speedSliderChanged:(NSSlider *)sender {
    NSNumber *speed = [NSNumber numberWithFloat:[sender floatValue] + 0.5f];
    [[self userSettings] setSpeed:speed];
    [[NSNotificationCenter defaultCenter] postNotificationName:speedChanged object:nil];
    [self notifySettingsChanged];
}

- (IBAction)unvoicedMultiplierChanged:(id)sender {
    NSNumber *multiplier = [NSNumber numberWithFloat:[sender floatValue]];
    [[self userSettings] setUnvoicedMultiplier:multiplier];
    [self notifySettingsChanged];
}

- (IBAction)inputGainChanged:(id)sender {
    NSNumber *gain = [NSNumber numberWithFloat:[sender floatValue]];
    [[self userSettings] setGain:gain];
    [[NSNotificationCenter defaultCenter] postNotificationName:speedChanged object:nil];
    [self notifySignalChanged];
    [self notifySettingsChanged];
}

- (IBAction)windowWidthChanged:(id)sender {
    [[self userSettings] setWindowWidth:[self numberFromString:[sender stringValue]]];
    [self notifySettingsChanged];
}

-(void)notifySignalChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:signalChanged object:nil];
}

-(void)notifySettingsChanged {
    if (self.frameData && [self hasInput]) [self showSpinner];
    [[NSNotificationCenter defaultCenter] postNotificationName:settingsChanged object:nil];
}

- (IBAction)startSampleChanged:(id)sender {
    NSNumber *sample = [NSNumber numberWithFloat:[sender intValue]];
    [[self userSettings] setStartSample:sample];
    [[NSNotificationCenter defaultCenter] postNotificationName:settingsChanged object:nil];
}

- (IBAction)endSampleChanged:(id)sender {
    NSNumber *sample = [NSNumber numberWithFloat:[sender intValue]];
    [[self userSettings] setEndSample:sample];
    [[NSNotificationCenter defaultCenter] postNotificationName:settingsChanged object:nil];
}

-(IBAction)translateParametersToggled:(NSButton *)sender {
    if (self.spinner.hidden) [self showSpinnerWithClearByteStream:NO];
    self.frameData = self.frameData;
}

-(BOOL)translate {
    return [self.translateParametersCheckbox state];
}

-(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

-(NSNumber *)numberFromString:(NSString *)string {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter numberFromString:string];
}

-(void)showSpinner {
    [self showSpinnerWithClearByteStream:YES];
}

-(void)showSpinnerWithClearByteStream:(BOOL)clearByteStream {
    self.spinner.hidden = NO;
    [self.spinner startAnimation:self];
    if (clearByteStream) self.byteStreamTextView.string = @"";
}

-(void)hideSpinner {
    self.spinner.hidden = YES;
    [self.spinner stopAnimation:self];
}

# pragma mark - NSTextViewDelegate

-(BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    [[NSNotificationCenter defaultCenter] postNotificationName:byteStreamChanged object:replacementString];
    return YES;
}

# pragma mark - NSTableViewDelegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *result = [tableView makeViewWithIdentifier:kFrameDataTableViewIdentifier owner:self];
    if (!result) {
        result = [[NSTextField alloc] initWithFrame:NSZeroRect];
        result.font = [NSFont systemFontOfSize:8];
        result.bezeled = NO;
        result.backgroundColor = [NSColor clearColor];
        result.identifier  = kFrameDataTableViewIdentifier;
        result.target = self;
        result.action = @selector(didEditTableViewCell:);
        result.objectValue = @"";
    }

    FrameData *frameData = [self.frameData objectAtIndex:row];
    if ([tableColumn.identifier isEqualToString:kFrameDataTableViewFrameKey]) {
        result.stringValue = [NSString stringWithFormat:@"%i%@", (int)row + 1, (frameData.shouldSkip ? @"x" : @"")];
    } else {
        NSDictionary *frame;
        if (self.translate) {
            frame = [frameData translatedParameters];
        } else {
            frame = [frameData parameters];
        }
        NSString *value = [[frame objectForKey:tableColumn.identifier] stringValue];
        if (frame) {
            result.stringValue = value ? value : @"";
        }
    }

    if (row == 0) {
        [self hideSpinner];
    }

    return result;
}

-(void)didEditTableViewCell:(NSTextField *)sender {
    NSString *valueString = [sender stringValue];
    NSUInteger row        = [self.frameDataTable rowForView:sender];
    NSUInteger column     = [self.frameDataTable columnForView:sender];
    FrameData *frameData  = [self.frameData objectAtIndex:row];

    if (!column) {
        frameData.skip = !![[valueString lowercaseString] rangeOfString:@"x"].location;
    } else {
        NSTableColumn *tableColumn = [[self.frameDataTable tableColumns] objectAtIndex:column];
        NSNumber *value = [self numberFromString:valueString];
        if (self.translate) {
            [frameData setParameter:tableColumn.identifier translatedValue:value];
        } else {
            [frameData setParameter:tableColumn.identifier value:value];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:frameWasEdited object:self.frameData];
}

# pragma mark - NSTableViewDataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.frameData count];
}

@end
