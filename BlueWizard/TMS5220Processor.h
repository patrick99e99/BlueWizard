#import "tms5220.h"
#import <Foundation/Foundation.h>

@protocol SpeechSynthesizerDelegate;

@interface TMS5220Processor : NSObject

-(instancetype)initWithSampleRate:(NSUInteger)sampleRate;
-(NSArray *)processLPC:(NSArray *)lpc;

@end
