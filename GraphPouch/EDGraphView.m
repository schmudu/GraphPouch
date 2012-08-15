//
//  EDGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDGraphView.h"
#import "EDWorksheetView.h"
#import "EDWorksheetElementView.h"
#import "EDConstants.h"
#import "EDGraph.h"
#import "NSManagedObject+EasyFetching.h"

@implementation EDGraphView
@synthesize graph;

- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph{
    self = [super initWithFrame:frame];
    if (self){
        //generate id
        [self setViewID:[EDGraphView generateID]];
        
        // listen
        EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
        NSManagedObjectContext *context = [coreData context];
        
        // listen
        _nc = [NSNotificationCenter defaultCenter];
        [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
        
        // set model info
        graph = myGraph;
        NSLog(@"creating graph view with graph: %@", myGraph);
    }
    return self;
}

- (void) dealloc{
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    NSManagedObjectContext *context = [coreData context];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = NSMakeRect(10, 10, 20, 20);
    
    // fill color based on selection
    if ([[graph valueForKey:@"selected"] isEqualToNumber:[[NSNumber alloc] initWithBool:TRUE]]){
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
    [self setFrameOrigin:NSMakePoint([[graph valueForKey:@"locationX"] floatValue], [[graph valueForKey:@"locationY"] floatValue])];
    
    [self setNeedsDisplay:TRUE];
}

#pragma mark mouse events
- (void)mouseDown:(NSEvent *)theEvent{
    NSUInteger flags = [theEvent modifierFlags];
    
    if ([[graph valueForKey:@"selected"] isEqualToNumber:[[NSNumber alloc] initWithBool:TRUE]]){
        // graph is already selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [graph setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:@"selected"];
        }
    } else {
        // graph is not selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [graph setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:@"selected"];
        }
        else {
#warning Need to deselect all the other graphs
            // post notification
            [_nc postNotificationName:EDEventUnselectedGraphClickedWithoutModifier object:self];
            
            //need to deselect all the other graphs
            [graph setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:@"selected"];
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
    //[[self graph] check];
    if(fabsf(diffX>0.01) && fabsf(diffY>0.01)){
        NSNumber *valueX = [[NSNumber alloc] initWithFloat:[self frame].origin.x];
        NSNumber *valueY = [[NSNumber alloc] initWithFloat:[self frame].origin.y];
        [[self graph] setValue:valueX forKey:@"locationX"];
        [[self graph] setValue:valueY forKey:@"locationY"];
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
        if([[[[updatedArray objectAtIndex:i] entity] name] isEqualToString:@"EDGraph"]){
            element = [updatedArray objectAtIndex:i];
            if (element == graph) {
                hasChanged = TRUE;
                [self updateDisplayBasedOnContext];
            }
        }
        i++;
    }
}

# pragma mark listeners - selection
- (void)onWorksheetSelectedElementAdded:(NSNotification *)note{
    [self setNeedsDisplay:TRUE];
}

- (void)onWorksheetSelectedElementRemoved:(NSNotification *)note{
    [self setNeedsDisplay:TRUE];
}
@end
