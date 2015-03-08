#import "WaveformView.h"
#import "Buffer.h"

@interface WaveformView ()
@property (nonatomic, weak) Buffer *buffer;
@end

@implementation WaveformView

-(instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputReceived:) name:@"inputReceived" object:nil];
    }
    return self;
}

-(void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);
    [[NSColor blueColor] set];
    [super drawRect:dirtyRect];
    if (!self.buffer) return;

    float zero = self.bounds.size.height / 2;

    float spacing = self.bounds.size.width / self.buffer.size;
    for (int i = 0; i < self.buffer.size - 1; i++) {
        NSBezierPath *line = [NSBezierPath bezierPath];
        NSPoint pointA = NSMakePoint(i * spacing, zero - (self.buffer.samples[i] * zero));
        NSPoint pointB = NSMakePoint((i + 1) * spacing, zero - (self.buffer.samples[i + 1] * zero));

        [line moveToPoint:pointA];
        [line lineToPoint:pointB];
        [line setLineWidth:1.0];
        [line stroke];
    }
}


-(void)inputReceived:(NSNotification *)notification {
    self.buffer = [notification object];
    [self setNeedsDisplay:YES];
}

@end
