#import <Foundation/Foundation.h>

@class Reflector;
@interface FrameData : NSObject

-(instancetype)initWithReflector:(Reflector *)reflector
                           pitch:(NSUInteger)pitch
                          repeat:(BOOL)repeat
                       translate:(BOOL)translate;
-(NSDictionary *)parameters;

@end
