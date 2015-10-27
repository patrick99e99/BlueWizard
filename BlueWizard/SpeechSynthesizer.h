#import <Foundation/Foundation.h>
@class Buffer;

@interface SpeechSynthesizer : NSObject

+(Buffer *)processSpeechData:(NSArray *)lpc;
-(Buffer *)processSpeechDataList:(NSArray *)concatenations;

@end
