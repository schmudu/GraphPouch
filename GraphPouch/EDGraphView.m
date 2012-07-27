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


- (id)initWithFrame:(NSRect)frame graphModel:(Graph *)myGraph{
    self = [super initWithFrame:frame];
    
    if (self){
        //generate id
        [self setViewID:[EDGraphView generateID]];
        
        // listen
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(onWorksheetSelectedElementRemoved:) name:EDEventWorksheetElementRemoved object:[self superview]];
        [nc addObserver:self selector:@selector(onWorksheetSelectedElementAdded:) name:EDEventWorksheetElementAdded object:[self superview]];
        //[nc addObserver:self selector:@selector(onGraphSelected:) name:EDEventElementSelected object:nil];
        
        // set model info
        graph = myGraph;
    }
    return self;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = NSMakeRect(10, 10, 20, 20);
    if([(EDWorksheetView *)[self superview] elementSelected:self])
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
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if(flags & NSCommandKeyMask){
        [dict setValue:@"command" forKey:@"key"];
        [nc postNotificationName:EDEventElementSelectedWithComand object:self userInfo:dict];
    }
    else if(flags & NSShiftKeyMask){
        [dict setValue:@"shift" forKey:@"key"];
        [nc postNotificationName:EDEventElementSelectedWithShift object:self userInfo:dict];
    }
    else{
        [nc postNotificationName:EDEventElementSelected object:self];
    }
    
    //save variable for undo
    savedFrameLocation = [self frame].origin;
    
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
    // last location of mouseDown
    //lastCursorLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    
    // current location
    //lastDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    float diffY = fabsf(lastCursorLocation.y - lastDragLocation.y);
    float diffX = fabsf(lastCursorLocation.x - lastDragLocation.x);
    //NSLog(@"diff?: %f eq?%d", diffY, (diffY>0.1f));
    
    //if no diff in location than do not prepare an undo
    if(fabsf(diffX>0.01) && fabsf(diffY>0.01)){
        // prepare undo
        NSUndoManager *undo = [self undoManager];
        [[undo prepareWithInvocationTarget:self] moveToSavedLocation];
        
        if (![undo isUndoing]) {
            [undo setActionName:@"Move Graph"];
        }
    }
}

# pragma mark listeners - graphs
- (void)onGraphSelected:(NSNotification *)note{
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //NSLog(@"new graph selected. self:%@", self);
    // was there a modifier key?
    if([note userInfo] == nil){
        // was this graph selected?
        if([note object] == self){
            [nc postNotificationName:EDEventElementSelected object:self];
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
            [nc postNotificationName:EDEventElementSelected object:self];
        }
    }
}

#pragma mark selection
/*
- (void)select{
    // prepare undo
    NSUndoManager *undo = [self undoManager];
    [[undo prepareWithInvocationTarget:self] deselect];
    
    if (![undo isUndoing]) {
        [undo setActionName:@"Select Graph"];
    }
    
    selected = TRUE;
    [self setNeedsDisplay:TRUE]; 
}

- (void)deselect{
    // prepare undo
    NSUndoManager *undo = [self undoManager];
    [[undo prepareWithInvocationTarget:self] select];
    
    if (![undo isUndoing]) {
        [undo setActionName:@"Select Graph"];
    }
    selected = FALSE;
    [self setNeedsDisplay:TRUE]; 
}*/

# pragma mark listeners - worksheet
/*
- (void)onWorksheetClicked:(NSNotification *)note{
    // deselect this graph
    if(selected){
        [self deselect];
    }
}*/

- (void)onWorksheetSelectedElementAdded:(NSNotification *)note{
    //selection was added
    
    /*
    //if in selection then show selected
    NSLog(@"figure out if added: superview:%@", [self superview]);
    if([(EDWorksheetView *)[self superview] elementSelected:self])
        NSLog(@"element is selected.");
    else
        NSLog(@"element is not selected.");
     */
    [self setNeedsDisplay:TRUE];
}

- (void)onWorksheetSelectedElementRemoved:(NSNotification *)note{
    //selection was added
    
    //if in selection then show selected
    //NSLog(@"figure out if removed");
    [self setNeedsDisplay:TRUE];
}

# pragma mark - movement
- (void)moveToSavedLocation{
    [self setFrameOrigin:savedFrameLocation];
}
@end
