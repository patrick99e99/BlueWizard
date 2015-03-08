#import "ViewController.h"

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

@end
//
//#import "ViewController.h"
//#import <AudioToolbox/AudioToolbox.h>
//
//typedef struct{
//    float progress;
//    float inc;
//    BOOL increasing;
//}SinStruct;
//
//
//
//@implementation ViewController{
//    SinStruct sinStruct;
//    
//    NSSlider *slider;
//    NSTextView *sliderFreqLabel;
//    NSBox *box;
//    float position;
//}
//
//- (void)viewDidLoad {
//    
//    [super viewDidLoad];
//    
//    slider = [[NSSlider alloc]initWithFrame:NSRectFromCGRect(CGRectMake(45, 45, 240, 45))];
//    slider.maxValue = 1760;
//    slider.minValue = 220;
//    slider.floatValue = 880;
//    
//    [slider setTarget:self];
//    [slider setAction:@selector(sliderTarget:)];
//    
//    sliderFreqLabel = [[NSTextView alloc]initWithFrame:NSRectFromCGRect(CGRectMake(45, 90, 240, 45))];
//    [sliderFreqLabel setString:[NSString stringWithFormat:@"%f",slider.floatValue]];
//    [self.view addSubview:sliderFreqLabel];
//    [self.view addSubview:slider];
//    
//    
//    sinStruct.progress = 0;
//    sinStruct.increasing = 1;
//    sinStruct.inc = 880 / 44100.0;  //       hz/sample rate
//    
//    
//    
//    box = [[NSBox alloc]initWithFrame:NSRectFromCGRect(CGRectMake(0, 100, 100, 100))];
//    box.fillColor = [NSColor colorWithRed:1 green:0 blue:0 alpha:1];
//    [self.view addSubview:box];
//    
//     __unused NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60.0 target:self selector:@selector(moveBox) userInfo:nil repeats:1];
//    
////        NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 / 60.0 target:self selector:@selector(moveBox) userInfo:nil repeats:1];
////        [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
//    
//    
//    [self performSelector:@selector(setUpAudioUnits) withObject:nil afterDelay:1];
//    
//}
//
//-(void)moveBox{
//    NSRect rect = box.frame;
//    rect.origin.x = position;
//    box.frame = rect;
//}
//
//
//
//
//-(void)sliderTarget:(NSSlider *)slider{
//    [sliderFreqLabel setString:[NSString stringWithFormat:@"%f",slider.floatValue]];
//    self->sinStruct.inc = slider.floatValue / 44100.0;
//}
//
//OSStatus my_callback(	void *							inRefCon,
//                     AudioUnitRenderActionFlags *	ioActionFlags,
//                     const AudioTimeStamp *			inTimeStamp,
//                     UInt32							inBusNumber,
//                     UInt32							inNumberFrames,
//                     AudioBufferList *				ioData){
//    
//    ViewController *self = (__bridge ViewController *)inRefCon;
//    
//    
//    self->position++;
//    
//    float *left = ioData->mBuffers[0].mData;
//    float *right = ioData->mBuffers[1].mData;
//    
//    for (int i = 0; i < inNumberFrames;i++){
//        
//        if (self->sinStruct.increasing){
//            self->sinStruct.progress = self->sinStruct.progress + self->sinStruct.inc;
//            
//            if (self->sinStruct.progress >= 1.0) {
//                self->sinStruct.increasing = 0;
//            }
//        }
//        else{
//            self->sinStruct.progress = self->sinStruct.progress - self->sinStruct.inc;
//            
//            if (self->sinStruct.progress <= -1.0) {
//                self->sinStruct.increasing = 1;
//            }
//        }
//        left[i] = sinf((self->sinStruct.progress * (M_PI / 2.0)));
//        right[i] = left[i];
//    }
//    return 0;
//}
//
//
//-(void)setUpAudioUnits{
//    AUGraph audioGraph;
//    NewAUGraph(&audioGraph);
//    
//    AUNode ioNode;
//    AudioComponentInstance ioUnit;
//    
//    AudioComponentDescription ioDesc = {0};
//    ioDesc.componentFlags = 0;
//    ioDesc.componentFlagsMask = 0;
//    ioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
//    ioDesc.componentSubType =  kAudioUnitSubType_DefaultOutput;
//    ioDesc.componentType    = kAudioUnitType_Output;
//    
//    AUGraphAddNode(audioGraph, &ioDesc, &ioNode);
//    AUGraphOpen(audioGraph);
//    AUGraphNodeInfo(audioGraph, ioNode, NULL, &ioUnit);
//    
//    AURenderCallbackStruct cbStruct = {my_callback, (__bridge void *)self};
//    AUGraphSetNodeInputCallback(audioGraph, ioNode, 0, &cbStruct);
//    
//    AUGraphInitialize(audioGraph);
//    AUGraphStart(audioGraph);
//    
//}
//
//
//
//
//
//
//- (void)setRepresentedObject:(id)representedObject {
//    [super setRepresentedObject:representedObject];
//    
//    // Update the view, if already loaded.
//}
//
//@end