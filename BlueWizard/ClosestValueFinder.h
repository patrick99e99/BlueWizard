#import <Foundation/Foundation.h>

@interface ClosestValueFinder : NSObject

+(NSUInteger)indexFor:(double)actual table:(float *)table size:(NSUInteger)size;

@end
