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
        [nc addObserver:self selector:@selector(onNewGraphSelected:) name:EDNotificationGraphSelectedWithShift object:nil];
        [nc addObserver:self selector:@selector(onNewGraphSelected:) name:EDNotificationGraphSelectedWithComand object:nil];
        [nc addObserver:self selector:@selector(onWorksheetClicked:) name:EDNotificationWorksheetClicked object:nil];
        
        // set model info
        graph = myGraph;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = NSMakeRect(10, 10, 20, 20);
    if(selected)
        [[NSColor redColor] set];
    else {
        [[NSColor greenColor] set];
    }
    [NSBezierPath fillRect:bounds];
    
    [super drawRect:dirtyRect];
}

#pragma mark mouse events
- (void)mouseDown:(NSEvent *)theEvent{
    NSUInteger flags = [theEvent modifierFlags];
    
    //post notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if(flags & NSCommandKeyMask){
        [dict setValue:@"command" forKey:@"key"];
        [nc postNotificationName:EDNotificationGraphSelectedWithComand object:self userInfo:dict];
    }
    else if(flags & NSShiftKeyMask){
        [dict setValue:@"shift" forKey:@"key"];
        [nc postNotificationName:EDNotificationGraphSelectedWithShift object:self userInfo:dict];
    }
    else{
        [nc postNotificationName:EDNotificationGraphSelected object:self];
    }
    
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

# pragma mark listeners - graphs
- (void)onNewGraphSelected:(NSNotification *)note{
    //NSLog(@"equal? %d", [note object] == self);
    // was there a modifier key?
    if([note userInfo] == nil){
        // was this graph selected?
        if([note object] == self){
            if(!selected){
                selected = TRUE;
                [self setNeedsDisplay:TRUE];
            }
        }
        else {
            // deselect this graph
            if(selected){
                selected = FALSE;
                [self setNeedsDisplay:TRUE];
            }
        }
    }
    else{
        // multiple selection
        // was this graph selected?
        if([note object] == self){
            if(!selected){
                selected = TRUE;
                [self setNeedsDisplay:TRUE];
            }
        }
        
    }
    NSLog(@"new graph selected: note: %d", [note userInfo] == nil);
}

# pragma mark listeners - worksheet
- (void)onWorksheetClicked:(NSNotification *)note{
    // deselect this graph
    if(selected){
        selected = FALSE;
        [self setNeedsDisplay:TRUE];
    }
}
@end
