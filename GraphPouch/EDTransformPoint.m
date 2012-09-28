//
//  EDTransformPoint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDTransformPoint.h"
#import "EDConstants.h"

@implementation EDTransformPoint

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mouseIsOver = FALSE;
        
        _nc = [NSNotificationCenter defaultCenter];
        
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

- (void)mouseDown:(NSEvent *)theEvent{
    // set variable for dragging
    _lastCursorLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    // set variable for draggin
    _lastDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint newDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    NSPoint thisOrigin = [self frame].origin;
    
    // alter origin
    thisOrigin.x += (-_lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-_lastDragLocation.y + newDragLocation.y);
    
    [self setFrameOrigin:thisOrigin];
    _lastDragLocation = newDragLocation;
    
    // dispatch event
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    [infoDic setValue:[[NSNumber alloc] initWithFloat:thisOrigin.x] forKey:@"locationX"];
    [infoDic setValue:[[NSNumber alloc] initWithFloat:thisOrigin.y] forKey:@"locationY"];
    [_nc postNotificationName:EDEventTransformPointDragged object:self userInfo:infoDic];
}

- (void)mouseUp:(NSEvent *)theEvent{
    [super mouseUp:theEvent];
    
    [_nc postNotificationName:EDEventTransformMouseUp object:self];
}
@end
