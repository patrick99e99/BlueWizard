#import "ClosestValueFinder.h"

@implementation ClosestValueFinder

+(NSNumber *)indexOrTranslatedValueFor:(NSNumber *)actual values:(NSArray *)values translate:(BOOL)translate {
    NSNumber *index = [self indexForClosestValue:actual values:values];
    return translate ?
        [NSNumber numberWithFloat:[[values objectAtIndex:[index unsignedIntegerValue]] floatValue]] :
        index;
}

+(NSNumber *)indexForClosestValue:(NSNumber *)actual values:(NSArray *)values {
    __block NSNumber *returnValue;
    [values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        float floatValue = [value floatValue];
        float floatActual = [actual floatValue];

        if (!idx && floatActual < floatValue) {
            returnValue = @0;
            *stop = YES;
            return;
        }
        
        if (floatValue > floatActual) {
            *stop = YES;

            float previousFloatValue = [[values objectAtIndex:idx - 1] floatValue];
            if (floatValue - floatActual < floatActual - previousFloatValue) {
                returnValue = [NSNumber numberWithUnsignedInteger:idx];
            } else {
                returnValue = [NSNumber numberWithUnsignedInteger:idx - 1];
            }
        }
        
    }];
    return returnValue ? returnValue : [NSNumber numberWithUnsignedInteger:[values count] - 1];
}

@end
