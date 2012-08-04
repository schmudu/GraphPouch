//
//  EDGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraphView.h"
#import "EDWorksheetView.h"
#import "EDWorksheetElementView.h"
#import "EDConstants.h"
#import "Graph.h"

@implementation EDGraphView
@synthesize graph;

- (id)initWithFrame:(NSRect)frame graphModel:(Graph *)myGraph{
    self = [super initWithFrame:frame];
    
    if (self){
        //generate id
        [self setViewID:[EDGraphView generateID]];
        
        // listen
        EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
        NSManagedObjectContext *context = [coreData context];
        
        // listen
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
        [nc addObserver:self selector:@selector(onWorksheetSelectedElementRemoved:) name:EDEventWorksheetElementRemoved object:[self superview]];
        [nc addObserver:self selector:@selector(onWorksheetSelectedElementAdded:) name:EDEventWorksheetElementAdded object:[self superview]];
        
        // set model info
        graph = myGraph;
    }
    return self;
}

- (void) dealloc{
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    NSManagedObjectContext *context = [coreData context];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];
    [nc removeObserver:self name:EDEventWorksheetElementRemoved object:[self superview]];
    [nc removeObserver:self name:EDEventWorksheetElementAdded object:[self superview]];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = NSMakeRect(10, 10, 20, 20);
    
    // fill color based on selection
    if([(EDWorksheetView *)[self superview] elementSelected:self])
        [[NSColor redColor] set];
    else {
        [[NSColor greenColor] set];
    }
    [NSBezierPath fillRect:bounds];
    
    [super drawRect:dirtyRect];
}

- (void)updateDisplayBasedOnContext{
    // move to position
    [self setFrameOrigin:NSMakePoint([graph locationX], [graph locationY])];
    
    [self setNeedsDisplay:TRUE];
}

#pragma mark mouse events
- (void)mouseDown:(NSEvent *)theEvent{
    NSUInteger flags = [theEvent modifierFlags];
    
    //post notification
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if(flags & NSCommandKeyMask){
        [dict setValue:@"command" forKey:@"key"];
        [nc postNotificationName:EDEventElementClickedWithCommand object:self userInfo:dict];
    }
    else if(flags & NSShiftKeyMask){
        [dict setValue:@"shift" forKey:@"key"];
        [nc postNotificationName:EDEventElementClickedWithShift object:self userInfo:dict];
    }
    else{
        [nc postNotificationName:EDEventElementClicked object:self];
    }
    
    // set variable for dragging
    lastCursorLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    
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
    NSPoint newDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    
    float diffY = fabsf(lastCursorLocation.y - lastDragLocation.y);
    float diffX = fabsf(lastCursorLocation.x - lastDragLocation.x);
    
    //if no diff in location than do not prepare an undo
    if(fabsf(diffX>0.01) && fabsf(diffY>0.01)){
        [[self graph] setLocationX:newDragLocation.x];
        [[self graph] setLocationY:newDragLocation.y];
    }
}

# pragma mark listeners - graphs
- (void)onContextChanged:(NSNotification *)note{
    NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
#warning move to category for checking for graphs
    // need to move this to a category
    BOOL hasChanged = FALSE;
    int i = 0;
    NSObject *element;
    //for(id element in updatedArray){
    while ((i<[updatedArray count]) && (!hasChanged)){    
        if([[[[updatedArray objectAtIndex:i] class] description] isEqualToString:@"Graph"]){
            element = [updatedArray objectAtIndex:i];
            if (element == graph) {
                hasChanged = TRUE;
                [self updateDisplayBasedOnContext];
                NSLog(@"this element has changed.");
            }
        }
        i++;
    }
    //NSLog(@"context changed: class: %@ eql?:%d", [element class], (element == graph));
}
/*
- (void)onGraphSelected:(NSNotification *)note{
    // was there a modifier key?
    if([note userInfo] == nil){
        // was this graph selected?
        if([note object] == self){
            [nc postNotificationName:EDEventElementClicked object:self];
        }
        else {
            NSLog(@"sending notification that graph was deselected.");
            [nc postNotificationName:EDEventElementDeselected object:self];
        }
    }
    else{
        // multiple selection
        // was this graph selected?
        if([note object] == self){
            [nc postNotificationName:EDEventElementClicked object:self];
        }
    }
}*/

# pragma mark listeners - selection
- (void)onWorksheetSelectedElementAdded:(NSNotification *)note{
    [self setNeedsDisplay:TRUE];
}

- (void)onWorksheetSelectedElementRemoved:(NSNotification *)note{
    [self setNeedsDisplay:TRUE];
}
@end
