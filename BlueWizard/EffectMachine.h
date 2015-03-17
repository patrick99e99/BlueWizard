#import <Foundation/Foundation.h>
@class Buffer;

@interface EffectMachine : NSObject

-(instancetype)initWithBuffer:(Buffer *)buffer;
-(void)process;

@end
