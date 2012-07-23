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
    if (self){
        graph = myGraph;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSLog(@"redrawing graph view: hasTickMarks:%@", [graph hasTickMarks]);
    //NSRect bounds = [self bounds];
    NSRect bounds = NSMakeRect(20, 20, 20, 20);
    [[NSColor redColor] set];
    [NSBezierPath fillRect:bounds];
    [super drawRect:dirtyRect];
}

#pragma mark Events
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
    NSLog(@"mouseUp");
}
@end
