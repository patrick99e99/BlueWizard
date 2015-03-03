#import <Foundation/Foundation.h>

@interface ClosestValueFinder : NSObject

+(float)translatedFloatFor:(float)actual floats:(float *)floats size:(NSUInteger)size;
+(int)translatedIntFor:(int)actual ints:(int *)ints size:(NSUInteger)size;
+(NSUInteger)indexFor:(float)actual floats:(float *)floats size:(NSUInteger)size;
+(NSUInteger)indexFor:(int)actual ints:(int *)ints size:(NSUInteger)size;
    
@end
