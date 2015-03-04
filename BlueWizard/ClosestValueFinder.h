#import <Foundation/Foundation.h>

@interface ClosestValueFinder : NSObject

+(NSUInteger)indexFor:(float)actual floats:(float *)floats size:(NSUInteger)size;
+(NSUInteger)indexFor:(int)actual ints:(int *)ints size:(NSUInteger)size;
    
@end
