#import "WaveformView.h"
#import "Buffer.h"

@interface WaveformView ()
@property (nonatomic) BOOL inverse;
@property (nonatomic) NSPoint mouseDown;
@property (nonatomic) NSPoint mouseUp;
@end

@implementation WaveformView

-(void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
    
    float zero = self.bounds.size.height / 2;
    [[NSColor blueColor] set];

    if (self.buffer) {

        float spacing = self.bounds.size.width / self.buffer.size;
        for (int i = 0; i < self.buffer.size - 1; i++) {
            NSPoint pointA = NSMakePoint(i * spacing, zero - (self.buffer.samples[i] * zero));
            NSPoint pointB = NSMakePoint((i + 1) * spacing, zero - (self.buffer.samples[i + 1] * zero));
            [self drawLineFromPointA:pointA toPointB:pointB];
        }
    }

    NSPoint pointA = NSMakePoint(0, zero);
    NSPoint pointB = NSMakePoint(self.bounds.size.width, zero);
    [self drawLineFromPointA:pointA toPointB:pointB];
}

-(void)drawLineFromPointA:(NSPoint)pointA toPointB:(NSPoint)pointB {
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:pointA];
    [line lineToPoint:pointB];

    [line setLineWidth:1.0];
    [line stroke];
}

-(void)setBuffer:(Buffer *)buffer {
    _buffer = buffer;
    [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)theEvent {
    self.inverse = YES;
    self.mouseDown = [theEvent locationInWindow];
    [self setNeedsDisplay:YES];
}

-(void)mouseUp:(NSEvent *)theEvent {
    self.inverse = NO;
    self.mouseUp = [theEvent locationInWindow];
    [self setNeedsDisplay:YES];
}

@end
