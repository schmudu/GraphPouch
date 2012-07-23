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
    //self = [super initWithFrame:frame];
    self = [super initWithFrame:NSMakeRect(20, 20, 20, 20)];
    
    if (self){
        graph = myGraph;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //NSLog(@"frame: x:%f y:%f bounds: x: %f y:%f", [self frame].origin.x, [self frame].origin.y, [self bounds].origin.x, [self bounds].origin.y);
    //NSLog(@"redrawing graph view: hasTickMarks:%@", [graph hasTickMarks]);
    NSRect bounds = [self bounds];
    //NSRect bounds = NSMakeRect(20, 20, 20, 20);
    [[NSColor redColor] set];
    [NSBezierPath fillRect:bounds];
    [super drawRect:dirtyRect];
}

#pragma mark Events
/*
- (NSView *)hitTest:(NSPoint)aPoint{
    NSPoint mousePoint = [self convertPoint:aPoint fromView:nil];
    NSRect bounds = [self bounds];
    if (NSPointInRect(aPoint, [self bounds])){
        NSLog(@"point is in rect: bounds: x:%f y:%f width:%f height:%f", bounds.origin.x, bounds.origin.y, bounds.size.width , bounds.size.height);
    }
    else {
        NSLog(@"point is outside rect: point x: %f y: %f bounds: x:%f y:%f width:%f height:%f", mousePoint.x, mousePoint.y, bounds.origin.x, bounds.origin.y, bounds.size.width , bounds.size.height);
    }
    
    return [super hitTest:aPoint];
}*/

- (void)mouseDown:(NSEvent *)theEvent{
    lastDragLocation = [theEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint newDragLocation = [theEvent locationInWindow];
    NSPoint thisOrigin = [self frame].origin;
    thisOrigin.x += (-lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-lastDragLocation.y + newDragLocation.y);
    [self setFrameOrigin:thisOrigin];
    lastDragLocation = newDragLocation;
    //NSLog(@"mouseDragged");
}

- (void)mouseUp:(NSEvent *)theEvent{
    //NSLog(@"mouseUp");
}
@end
