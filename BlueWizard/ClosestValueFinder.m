#import "ClosestValueFinder.h"

@implementation ClosestValueFinder

+(NSUInteger)indexFor:(double)actual table:(float *)table size:(NSUInteger)size {
    if (actual < table[0]) return 0;
    
    for (int i = 1; i < size; i++) {
        if (table[i] > actual) {
            float previous = table[i - 1];
            if (table[i] - actual < actual - previous) {
                return i;
            } else {
                return i - 1;
            }
        }
    }
    return size - 1;
}

@end
