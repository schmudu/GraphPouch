//
//  EDWorksheetElementView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/26/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDWorksheetElementView.h"
#import "EDWorksheetView.h"
#import "EDWorksheetElementView.h"
#import "EDConstants.h"
#import "EDGraph.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSManagedObject+Attributes.h"
#import "EDCoreDataUtility.h"

@interface EDWorksheetElementView()
- (void)mouseDownBehavior:(NSEvent *)theEvent;
- (void)mouseUpBehavior:(NSEvent *)theEvent;
- (void)mouseDraggedBehavior:(NSEvent *)theEvent;
@end

@implementation EDWorksheetElementView
@synthesize viewID;
@synthesize dataObj;

+ (NSString *)generateID{
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMDDHHmmssA"];
    NSString *dateString = [format stringFromDate:now];
    NSString *returnStr = [[[NSString alloc] initWithFormat:@"element"] stringByAppendingString:dateString];
    //NSLog(@"creating id of: %@", returnStr);
    return returnStr;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}


- (void)updateDisplayBasedOnContext{
    // move to position
    [self setFrameOrigin:NSMakePoint([[[self dataObj] valueForKey:EDElementAttributeLocationX] floatValue], [[[self dataObj] valueForKey:EDElementAttributeLocationY] floatValue])];
    
    [self setNeedsDisplay:TRUE];
}

#pragma mark mouse events
#pragma mark mouse down
- (void)mouseDown:(NSEvent *)theEvent{
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    [coreData getAllObjects];
    
    NSUInteger flags = [theEvent modifierFlags];
    
    if ([[self dataObj] isSelectedElement]){
        // graph is already selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDElementAttributeSelected];
        }
        else{
            // notify listeners of mouse down
            NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
            [notificationDictionary setValue:theEvent forKey:EDEventKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDown object:self userInfo:notificationDictionary];
        }
    } else {
        // graph is not selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
        }
        else {
#warning Need to deselect all the other graphs
            // post notification
            [_nc postNotificationName:EDEventUnselectedGraphClickedWithoutModifier object:self];
            
            //need to deselect all the other graphs
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
        }
    }
    
    // set variable for dragging
    lastCursorLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    
    // set variable for draggin
    lastDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
}

- (void)mouseDownBySelection:(NSEvent *)theEvent{
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    [coreData getAllObjects];
    
    NSUInteger flags = [theEvent modifierFlags];
    
    if ([[self dataObj] isSelectedElement]){
        // graph is already selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDElementAttributeSelected];
        }
    } else {
        // graph is not selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
        }
        else {
#warning Need to deselect all the other graphs
            // post notification
            [_nc postNotificationName:EDEventUnselectedGraphClickedWithoutModifier object:self];
            
            //need to deselect all the other graphs
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
        }
    }
    
    // set variable for dragging
    lastCursorLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    
    // set variable for draggin
    lastDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
}
/*
- (void)mouseDown:(NSEvent *)theEvent{
    [self mouseDownBehavior:theEvent];
    
    // notify listeners
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    [notificationDictionary setValue:theEvent forKey:EDEventKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDown object:self userInfo:notificationDictionary];
}

- (void)mouseDownBySelection:(NSEvent *)theEvent{
    [self mouseDownBehavior:theEvent];
}

- (void)mouseDownBehavior:(NSEvent *)theEvent{
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    [coreData getAllObjects];
    
    NSUInteger flags = [theEvent modifierFlags];
    
    if ([[self dataObj] isSelectedElement]){
        // graph is already selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDElementAttributeSelected];
        }
    } else {
        // graph is not selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
        }
        else {
#warning Need to deselect all the other graphs
            // post notification
            [_nc postNotificationName:EDEventUnselectedGraphClickedWithoutModifier object:self];
            
            //need to deselect all the other graphs
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
        }
    }
    
    // set variable for dragging
    lastCursorLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    
    // set variable for draggin
    lastDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
}*/

#pragma mark mouse dragged
- (void)mouseDragged:(NSEvent *)theEvent{
    [self mouseDraggedBehavior:theEvent];
    
    // notify listeners
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    [notificationDictionary setValue:theEvent forKey:EDEventKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDragged object:self userInfo:notificationDictionary];
}

- (void)mouseDraggedBySelection:(NSEvent *)theEvent{
    [self mouseDraggedBehavior:theEvent];
}

- (void)mouseDraggedBehavior:(NSEvent *)theEvent{
    NSPoint newDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSPoint thisOrigin = [self frame].origin;
    
    // alter origin
    thisOrigin.x += (-lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-lastDragLocation.y + newDragLocation.y);
    
    [self setFrameOrigin:thisOrigin];
    lastDragLocation = newDragLocation;
}

#pragma mark mouse up
- (void)mouseUp:(NSEvent *)theEvent{
    [self mouseUpBehavior:theEvent];
    
    // notify listeners
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    [notificationDictionary setValue:theEvent forKey:EDEventKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseUp object:self userInfo:notificationDictionary];
}

- (void)mouseUpBySelection:(NSEvent *)theEvent{
    [self mouseUpBehavior:theEvent];
}

- (void)mouseUpBehavior:(NSEvent *)theEvent{
    float diffY = fabsf(lastCursorLocation.y - lastDragLocation.y);
    float diffX = fabsf(lastCursorLocation.x - lastDragLocation.x);
    
    //if no diff in location than do not prepare an undo
    //[[self graph] check];
    if(fabsf(diffX>0.01) && fabsf(diffY>0.01)){
        NSNumber *valueX = [[NSNumber alloc] initWithFloat:[self frame].origin.x];
        NSNumber *valueY = [[NSNumber alloc] initWithFloat:[self frame].origin.y];
        [[self dataObj] setValue:valueX forKey:EDElementAttributeLocationX];
        [[self dataObj] setValue:valueY forKey:EDElementAttributeLocationY];
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
        if([[[[updatedArray objectAtIndex:i] entity] name] isEqualToString:EDEntityNameGraph]){
            element = [updatedArray objectAtIndex:i];
            if (element == [self dataObj]) {
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
