#import <Foundation/Foundation.h>

#ifndef BlueWizard_SpeechSynthesizerDelegate_h
#define BlueWizard_SpeechSynthesizerDelegate_h

@class Buffer;
@protocol SamplerDelegate <NSObject>

-(void)didFinishStreaming:(Buffer *)buffer;

@end

#endif
