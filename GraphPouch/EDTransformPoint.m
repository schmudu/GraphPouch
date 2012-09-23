//
//  EDTransformPoint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDTransformPoint.h"

@implementation EDTransformPoint

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mouseIsOver = FALSE;
        
        // add tracking area
        [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds] options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil]];
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blueColor] set];
    if(_mouseIsOver){
        [NSBezierPath fillRect:[self bounds]];
    }
    else {
        [NSBezierPath strokeRect:[self bounds]];
    }
}

#pragma mark mouse
- (void)mouseEntered:(NSEvent *)theEvent{
    _mouseIsOver = TRUE;
    [self setNeedsDisplay:TRUE];
}

- (void)mouseExited:(NSEvent *)theEvent{
    _mouseIsOver = FALSE;
    [self setNeedsDisplay:TRUE];
}
@end
