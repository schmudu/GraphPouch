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
#import "NSManagedObject+EasyFetching.h"

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
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = NSMakeRect(10, 10, 20, 20);
    
    // fill color based on selection
    //if([(EDWorksheetView *)[self superview] elementSelected:self])
    if ([graph selected]) {
        [[NSColor redColor] set];
    }
    else {
        [[NSColor greenColor] set];
    }
    [NSBezierPath fillRect:bounds];
    
    [super drawRect:dirtyRect];
}

- (void)updateDisplayBasedOnContext{
    // move to position
    //NSLog(@"moving frame origin to: x:%f y:%f lastCursor x:%f y:%f lastDrag: x:%f y:%f", [graph locationX], [graph locationY], lastCursorLocation.x, lastCursorLocation.y, lastDragLocation.x, lastDragLocation.y);
    [self setFrameOrigin:NSMakePoint([graph locationX], [graph locationY])];
    
    [self setNeedsDisplay:TRUE];
}

#pragma mark mouse events
- (void)mouseDown:(NSEvent *)theEvent{
    NSUInteger flags = [theEvent modifierFlags];
    
    //NSLog(@"working:%@", [Graph findAllSelectedObjects]);
    if ([graph selected]) {
        // graph is already selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [graph setSelected:FALSE];
        }
    } else {
        // graph is not selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [graph setSelected:TRUE];
        }
        else {
#warning need to figure out how to deselect the other graphs
            //need to deselect all the other graphs
            
            [graph setSelected:TRUE];
        }
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
    float diffY = fabsf(lastCursorLocation.y - lastDragLocation.y);
    float diffX = fabsf(lastCursorLocation.x - lastDragLocation.x);
    
    //if no diff in location than do not prepare an undo
    if(fabsf(diffX>0.01) && fabsf(diffY>0.01)){
        [[self graph] setLocationX:[self frame].origin.x];
        [[self graph] setLocationY:[self frame].origin.y];
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
            }
        }
        i++;
    }
    //NSLog(@"context changed: class: %@ eql?:%d", [element class], (element == graph));
}

# pragma mark listeners - selection
- (void)onWorksheetSelectedElementAdded:(NSNotification *)note{
    [self setNeedsDisplay:TRUE];
}

- (void)onWorksheetSelectedElementRemoved:(NSNotification *)note{
    [self setNeedsDisplay:TRUE];
}
@end
