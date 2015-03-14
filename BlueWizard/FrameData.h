#import <Foundation/Foundation.h>

@class Reflector;
@interface FrameData : NSObject

-(instancetype)initWithReflector:(Reflector *)reflector
                           pitch:(NSUInteger)pitch
                          repeat:(BOOL)repeat;
-(NSDictionary *)parameters;
-(NSDictionary *)translatedParameters;
-(void)setParameter:(NSString *)parameter
              value:(NSNumber *)value;
-(Reflector *)reflector;

@end
