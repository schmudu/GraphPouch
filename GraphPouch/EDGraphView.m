//
//  EDGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraphView.h"
#import "EDWorksheetView.h"
#import "EDConstants.h"
#import "Graph.h"

@implementation EDGraphView
@synthesize viewID;

+ (NSString *)generateID{
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMDDHHmmssA"];
    NSString *dateString = [format stringFromDate:now];
    NSString *returnStr = [[[NSString alloc] initWithFormat:@"graph"] stringByAppendingString:dateString];
    NSLog(@"creating id of: %@", returnStr);
    return returnStr;
}

- (id)initWithFrame:(NSRect)frame graphModel:(Graph *)myGraph{
    self = [super initWithFrame:frame];
    
    if (self){
        //generate id
        [self setViewID:[EDGraphView generateID]];
        
        // listen
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        //[nc addObserver:self selector:@selector(onNewGraphSelected:) name:EDNotificationGraphSelected object:self];
        //[nc addObserver:self selector:@selector(onNewGraphSelected:) name:EDNotificationGraphSelectedWithShift object:self];
        //[nc addObserver:self selector:@selector(onNewGraphSelected:) name:EDNotificationGraphSelectedWithComand object:self];
        //[nc addObserver:self selector:@selector(onWorksheetClicked:) name:EDNotificationWorksheetClicked object:self];
        [nc addObserver:self selector:@selector(onWorksheetSelectedElementRemoved:) name:EDNotificationWorksheetElementRemoved object:nil];
        [nc addObserver:self selector:@selector(onWorksheetSelectedElementAdded:) name:EDNotificationWorksheetElementAdded object:nil];
        
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
    lastLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    
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
    // prepare undo
    NSUndoManager *undo = [self undoManager];
    [[undo prepareWithInvocationTarget:self] moveToSavedLocation];
    
    if (![undo isUndoing]) {
        [undo setActionName:@"Move Graph"];
    }
}

# pragma mark listeners - graphs
- (void)onNewGraphSelected:(NSNotification *)note{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"new graph selected. self:%@", self);
    // was there a modifier key?
    if([note userInfo] == nil){
        // was this graph selected?
        if([note object] == self){
            [nc postNotificationName:EDNotificationGraphSelected object:self];
        }
        else {
            [nc postNotificationName:EDNotificationGraphDeselected object:self];
        }
    }
    else{
        // multiple selection
        // was this graph selected?
        if([note object] == self){
            [nc postNotificationName:EDNotificationGraphSelected object:self];
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
    
    //if in selection then show selected
    NSLog(@"figure out if added: superview:%@", [self superview]);
    if([(EDWorksheetView *)[self superview] elementSelected:self])
        NSLog(@"element is selected.");
    else
        NSLog(@"element is not selected.");
}

- (void)onWorksheetSelectedElementRemoved:(NSNotification *)note{
    //selection was added
    
    //if in selection then show selected
    NSLog(@"figure out if removed");
}

# pragma mark - movement
- (void)moveToSavedLocation{
    [self setFrameOrigin:lastLocation];
}
@end
