#import <Cocoa/Cocoa.h>
#import "SamplerDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, SamplerDelegate>

-(BOOL)hasInput;

@end

