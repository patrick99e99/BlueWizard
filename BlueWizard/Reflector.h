#import <Foundation/Foundation.h>

@interface Reflector : NSObject

-(BOOL)isVoiced;
-(BOOL)isUnvoiced;
-(NSUInteger)rms;
-(float *)ks;

@end
