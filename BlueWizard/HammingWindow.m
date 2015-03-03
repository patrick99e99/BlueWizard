#import "HammingWindow.h"
#import "Buffer.h"

@implementation HammingWindow

+(void)processBuffer:(Buffer *)buffer {
    for (int i=0; i < buffer.size; i++) {
        float window = 0.54f - 0.46f * cos(2 * M_PI * i / (buffer.size - 1));
        buffer.samples[i] *= window;
    }
}

@end