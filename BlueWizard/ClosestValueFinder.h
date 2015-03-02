#import <Foundation/Foundation.h>

@interface ClosestValueFinder : NSObject

+(NSNumber *)indexOrTranslatedValueFor:(NSNumber *)actual values:(NSArray *)values translate:(BOOL)translate;

@end
