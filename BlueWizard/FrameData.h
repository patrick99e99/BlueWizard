#import <Foundation/Foundation.h>

@class Reflector;
@interface FrameData : NSObject

@property (nonatomic, getter=shouldSkip) BOOL skip;

+(FrameData *)stopFrame;
+(FrameData *)frameForDecoding;
-(instancetype)initWithReflector:(Reflector *)reflector
                           pitch:(NSUInteger)pitch
                          repeat:(BOOL)repeat;
-(NSDictionary *)parameters;
-(NSDictionary *)translatedParameters;
-(void)setParameter:(NSString *)parameter
              value:(NSNumber *)value;
-(void)setParameter:(NSString *)parameter
    translatedValue:(NSNumber *)translatedValue;
-(Reflector *)reflector;

@end
