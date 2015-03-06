#import <Foundation/Foundation.h>

@class Buffer;
@interface Segmenter : NSObject

-(instancetype)initWithBuffer:(Buffer *)buffer
                  windowWidth:(NSUInteger)windowWidth;
-(void)eachSegment:(void (^)(Buffer *buffer, NSUInteger index))block;
-(NSUInteger)numberOfSegments;

@end
                    