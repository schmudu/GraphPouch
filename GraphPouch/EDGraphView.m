//
//  EDGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraphView.h"
#import "Graph.h"

@implementation EDGraphView

- (id)initWithFrame:(NSRect)frame graphModel:(Graph *)myGraph{
    self = [super initWithFrame:frame];
    //self = [super initWithFrame:NSMakeRect(20, 20, 20, 20)];
    
    if (self){
        graph = myGraph;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //NSLog(@"frame: x:%f y:%f bounds: x: %f y:%f", [self frame].origin.x, [self frame].origin.y, [self bounds].origin.x, [self bounds].origin.y);
    //NSLog(@"redrawing graph view: hasTickMarks:%@", [graph hasTickMarks]);
    //NSRect bounds = [self bounds];
    [[NSColor greenColor] set];
    [NSBezierPath fillRect:[self bounds]];
    
    NSRect bounds = NSMakeRect(10, 10, 20, 20);
    [[NSColor redColor] set];
    [NSBezierPath fillRect:bounds];
    
    [super drawRect:dirtyRect];
}

#pragma mark Events

- (void)mouseDown:(NSEvent *)theEvent{
    NSInteger clicks = [theEvent clickCount];
    NSLog(@"mouseUp: %ld", clicks);
    lastDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint newDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSPoint thisOrigin = [self frame].origin;
    
    // alter origin
    thisOrigin.x += (-lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-lastDragLocation.y + newDragLocation.y);
    
    [self setFrameOrigin:thisOrigin];
    lastDragLocation = newDragLocation;
}

- (void)mouseUp:(NSEvent *)theEvent{
    //NSLog(@"mouseUp");
}
@end
