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
- (void)mouseUpBehavior:(NSEvent *)theEvent;
- (void)mouseDraggedBehavior:(NSEvent *)theEvent;
- (void)notifyMouseDownListeners:(NSEvent *)theEvent;
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

- (BOOL)isFlipped{
    return TRUE;
}


- (void)updateDisplayBasedOnContext{
    // move to position
    [self setFrameOrigin:NSMakePoint([[[self dataObj] valueForKey:EDElementAttributeLocationX] floatValue], [[[self dataObj] valueForKey:EDElementAttributeLocationY] floatValue])];
    
    [self setNeedsDisplay:TRUE];
}

#pragma mark mouse events
#pragma mark mouse down
- (void)mouseDown:(NSEvent *)theEvent{
    // CAREFUL: any code you change here needs to change in the "mouseDownBySelection" method
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    [coreData getAllObjects];
    
    NSUInteger flags = [theEvent modifierFlags];
 
    //save mouse location
    _savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
    _didSnap = FALSE;
    //NSLog(@"saved mous location:x:%f y:%f", _savedMouseSnapLocation.x, _savedMouseSnapLocation.y);
    
    if ([[self dataObj] isSelectedElement]){
        // graph is already selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDElementAttributeSelected];
        }
        else{
            [self notifyMouseDownListeners:theEvent];
        }
    } else {
        // graph is not selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
        }
        else {
            // post notification
            [_nc postNotificationName:EDEventUnselectedGraphClickedWithoutModifier object:self];
            
            //need to deselect all the other graphs
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
            
            [self notifyMouseDownListeners:theEvent];
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
    _savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
    
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

- (void)notifyMouseDownListeners:(NSEvent *)theEvent{
    // notify listeners of mouse down
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    [notificationDictionary setValue:theEvent forKey:EDEventKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDown object:self userInfo:notificationDictionary];
}

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only do if we're snapping
    if ([defaults boolForKey:EDPreferenceSnapToGuides]) {
        float closestVerticalPointToOrigin;
        float closestVerticalPointToEdge;
        NSMutableDictionary *guides = [(EDWorksheetView *)[self superview] guides];
        // get vertical guide as long as there are guides to go by
        if ([[guides objectForKey:EDKeyGuideVertical] count] > 0) {
            closestVerticalPointToOrigin = [self findClosestPoint:thisOrigin.y guides:[guides objectForKey:EDKeyGuideVertical]];
            closestVerticalPointToEdge = [self findClosestPoint:(thisOrigin.y + [[self dataObj] elementHeight]) guides:[guides objectForKey:EDKeyGuideVertical]];
            
            // snap if close enough to edges of object
            //if ((fabsf(thisOrigin.y - closestVerticalPointToOrigin) < EDGuideThreshold) || ( fabsf((thisOrigin.y + [[self dataObj] elementHeight]) - closestVerticalPointToOrigin)< EDGuideThreshold)) {
            NSLog(@"going to snap to origin: y: %f or far edge: %f closest edge point: %f", thisOrigin.y, thisOrigin.y + [[self dataObj] elementHeight], closestVerticalPointToEdge);
            if ((fabsf(thisOrigin.y - closestVerticalPointToOrigin) < EDGuideThreshold)) {
                _didSnap = TRUE;
                
                //NSLog(@"snapping...location: x:%f y:%f", mouseLocation.x, mouseLocation.y);
                float originalVerticalPoint = thisOrigin.y;
                thisOrigin.y = closestVerticalPointToOrigin;
                
                //notify other selected points that we did snap
                NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
                [infoDictionary setValue:[[NSNumber alloc] initWithFloat:(originalVerticalPoint - thisOrigin.y)] forKey:EDKeySnapOffset];
                [[NSNotificationCenter defaultCenter] postNotificationName:EDEventElementSnapped object:self userInfo:infoDictionary];
            }
            else if ((fabsf((thisOrigin.y + [[self dataObj] elementHeight]) - closestVerticalPointToEdge) < EDGuideThreshold)) {
                _didSnap = TRUE;
                
                NSLog(@"snapping to edge.");
                float originalVerticalPoint = thisOrigin.y;
                thisOrigin.y = closestVerticalPointToEdge - [[self dataObj] elementHeight];
                
                //notify other selected points that we did snap
                NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
                //NSPoint currentLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
                [infoDictionary setValue:[[NSNumber alloc] initWithFloat:(originalVerticalPoint - thisOrigin.y)] forKey:EDKeySnapOffset];
                [[NSNotificationCenter defaultCenter] postNotificationName:EDEventElementSnapped object:self userInfo:infoDictionary];
            }
            else{
                if(_didSnap){
                    // reset
                    _didSnap = FALSE;
                    
                    // snap back to original location
                    NSPoint currentLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
                    thisOrigin.y += (currentLocation.y - _savedMouseSnapLocation.y);
                }
            }
        }
        else{
            _didSnap = FALSE;
        }
    }
    
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
    if(fabsf(diffX>0.01) && fabsf(diffY>0.01)){
        NSNumber *valueX = [[NSNumber alloc] initWithFloat:[self frame].origin.x];
        NSNumber *valueY = [[NSNumber alloc] initWithFloat:[self frame].origin.y];
        [[self dataObj] setValue:valueX forKey:EDElementAttributeLocationX];
        [[self dataObj] setValue:valueY forKey:EDElementAttributeLocationY];
    }
}

- (void)snapToPoint:(float)snapOffset{
    // only elements that didn't snap need to move
    if(!_didSnap){
        NSLog(@"need to snap this element by offset: %f", snapOffset);
    }
}

# pragma mark listeners - graphs
- (void)onContextChanged:(NSNotification *)note{
    // this enables undo method to work
    NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    
    BOOL hasChanged = FALSE;
    int i = 0;
    NSObject *element;
    
    // search through updated array and see if this element has changed
    while ((i<[updatedArray count]) && (!hasChanged)){    
            element = [updatedArray objectAtIndex:i];
            if (element == [self dataObj]) {
                hasChanged = TRUE;
                [self updateDisplayBasedOnContext];
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

# pragma mark snap
- (float)findClosestPoint:(float)currentPoint guides:(NSMutableArray *)guides{
    // go through guides and find closest point
    float smallestDiff = 999999;
    float closestPoint;
    
    // iterate through all the
    for (NSNumber *point in guides){
        if (fabsf(currentPoint - [point floatValue]) < smallestDiff) {
            // found smallest point so far
            smallestDiff = fabsf(currentPoint - [point floatValue]);
            closestPoint = [point floatValue];
        }
    }
    return closestPoint;
}
@end
