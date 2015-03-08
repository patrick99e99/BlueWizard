#import "PlayheadView.h"
#import "Sampler.h"

@interface PlayheadView ()
@property (nonatomic) float containerWidth;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation PlayheadView

-(instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.containerWidth = self.superview.frame.size.width;
    }
    return self;
}

-(void)setSampler:(Sampler *)sampler {
    _sampler = sampler;
    if (self.timer) return;
    self.timer = [NSTimer timerWithTimeInterval:1.0 / 60.0 target:self selector:@selector(updatePosition) userInfo:nil repeats:1];
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)drawRect:(NSRect)dirtyRect {
    [[NSColor redColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

-(void)updatePosition {
    float position = self.containerWidth / self.sampler.bufferSize * self.sampler.index;
    [self setFrameOrigin:NSMakePoint(position, 0)];
}

@end
