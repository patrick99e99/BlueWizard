#import "HammingWindow.h"
#import "Buffer.h"

@implementation HammingWindow

+(void)processBuffer:(Buffer *)buffer {
    for (int i=0; i < buffer.size; i++) {
        double window = 0.54f - 0.46f * (double long)cos(2 * M_PI * i / (buffer.size - 1));
        buffer.samples[i] *= window;
    }
}

@end