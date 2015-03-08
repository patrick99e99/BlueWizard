#import <Foundation/Foundation.h>
@class Buffer, PlayheadView;
@protocol SamplerDelegate;
@interface Sampler : NSObject

@property (nonatomic, weak) PlayheadView *playheadView;

-(instancetype)initWithDelegate:(id<SamplerDelegate>)delegate;
-(void)stream:(Buffer *)buffer;
-(void)stop;
-(NSUInteger)index;
-(NSUInteger)bufferSize;

@end
