#import "WaveformView.h"
#import "Buffer.h"

@interface WaveformView ()
@property (nonatomic) BOOL inverse;
@property (nonatomic) NSPoint mouseDown;
@property (nonatomic) NSPoint mouseUp;
@property (nonatomic, strong) NSImage *image;
@end

@implementation WaveformView

-(instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self render];
    }
    return self;
}

-(void)drawRect:(NSRect)dirtyRect {
    [self.image drawInRect:dirtyRect];
    [super drawRect:dirtyRect];
}

-(void)render {
    CGFloat scale  = 1.0f;
    CGFloat width  = self.bounds.size.width * scale;
    CGFloat height = self.bounds.size.height * scale;

    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    
    [image lockFocus];
    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);
    
    float zero = height / 2.0f;
    [[NSColor blueColor] set];
    
    NSPoint pointA = NSMakePoint(0, zero);
    NSPoint pointB = NSMakePoint(width, zero);
    [self drawLineFromPointA:pointA toPointB:pointB];
    
    if (self.buffer) {
        float spacing = width / self.buffer.size;
        for (int i = 0; i < self.buffer.size - 1; i++) {
            NSPoint pointA = NSMakePoint(i * spacing, zero + (self.buffer.samples[i] * zero));
            NSPoint pointB = NSMakePoint((i + 1) * spacing, zero + (self.buffer.samples[i + 1] * zero));
            [self drawLineFromPointA:pointA toPointB:pointB];
        }
    }

    [image unlockFocus];
    
    self.image = image;
}

-(void)drawLineFromPointA:(NSPoint)pointA toPointB:(NSPoint)pointB {
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:pointA];
    [line lineToPoint:pointB];
    
    [line setLineWidth:1.0f];
    [line stroke];
}

-(void)setBuffer:(Buffer *)buffer {
    _buffer = buffer;
    [self render];
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
