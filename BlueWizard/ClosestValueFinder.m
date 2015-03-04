#import "ClosestValueFinder.h"

@implementation ClosestValueFinder

+(NSUInteger)indexFor:(float)actual floats:(float *)floats size:(NSUInteger)size {
    if (actual < floats[0]) return 0;
    
    for (int i = 1; i < size; i++) {
        if (floats[i] > actual) {
            float previous = floats[i - 1];
            if (floats[i] - actual < actual - previous) {
                return i;
            } else {
                return i - 1;
            }
        }
    }
    return size - 1;
}

+(NSUInteger)indexFor:(int)actual ints:(int *)ints size:(NSUInteger)size {
    if (actual < ints[0]) return 0;
    
    for (int i = 1; i < size; i++) {
        if (ints[i] > actual) {
            int previous = ints[i - 1];
            if (ints[i] - actual < actual - previous) {
                return i;
            } else {
                return i - 1;
            }
        }
    }
    return size - 1;
}

@end
