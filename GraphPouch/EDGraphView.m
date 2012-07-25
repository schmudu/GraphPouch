//
//  EDGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraphView.h"
#import "EDConstants.h"
#import "Graph.h"

@implementation EDGraphView

- (id)initWithFrame:(NSRect)frame graphModel:(Graph *)myGraph{
    self = [super initWithFrame:frame];
    //self = [super initWithFrame:NSMakeRect(20, 20, 20, 20)];
    
    if (self){
        // listen
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(onNewGraphSelected:) name:EDNotificationGraphSelected object:nil];
        
        // set model info
        graph = myGraph;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //NSLog(@"frame: x:%f y:%f bounds: x: %f y:%f", [self frame].origin.x, [self frame].origin.y, [self bounds].origin.x, [self bounds].origin.y);
    //NSLog(@"redrawing graph view: hasTickMarks:%@", [graph hasTickMarks]);
    //NSRect bounds = [self bounds];
    //[[NSColor greenColor] set];
    //[NSBezierPath fillRect:[self bounds]];
    
    NSRect bounds = NSMakeRect(10, 10, 20, 20);
    if(selected)
        [[NSColor redColor] set];
    else {
        [[NSColor greenColor] set];
    }
    [NSBezierPath fillRect:bounds];
    
    [super drawRect:dirtyRect];
}

#pragma mark Events

- (void)mouseDown:(NSEvent *)theEvent{
    //NSInteger clicks = [theEvent clickCount];
    //NSLog(@"mouseUp: %ld", clicks);
    
    //post notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:EDNotificationGraphSelected object:self];
    
    // set variable for draggin
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

- (void)onNewGraphSelected:(NSNotification *)note{
    NSLog(@"equal? %d", [note object] == self);
    if([note object] == self){
        if(!selected){
            selected = TRUE;
            [self setNeedsDisplay:TRUE];
        }
    }
    else {
        if(selected){
            NSLog(@"switching back to false.");
            selected = FALSE;
            [self setNeedsDisplay:TRUE];
        }
    }
    NSLog(@"new graph selected: note: %@", [note object]);
}
@end
