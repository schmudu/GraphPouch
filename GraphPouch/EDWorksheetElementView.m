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
#import "NSObject+Document.h"

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
        NSManagedObjectContext *context = [self currentContext];
        
        // listen
        _nc = [NSNotificationCenter defaultCenter];
        [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
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
    // update position
    [self setFrame:NSMakeRect([[[self dataObj] valueForKey:EDElementAttributeLocationX] floatValue], 
                              [[[self dataObj] valueForKey:EDElementAttributeLocationY] floatValue],
                              [[[self dataObj] valueForKey:EDElementAttributeWidth] floatValue],
                              [[[self dataObj] valueForKey:EDElementAttributeHeight] floatValue])];
                              
    [self setNeedsDisplay:TRUE];
}

#pragma mark mouse events
#pragma mark mouse down
- (void)mouseDown:(NSEvent *)theEvent{
#warning CAREFUL: any code you change here needs to change in the "mouseDownBySelection" method
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    [coreData getAllObjects];
    
    NSUInteger flags = [theEvent modifierFlags];
 
    //save mouse location
    //_savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
    _savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    _didSnap = FALSE;
    
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
    //lastCursorLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    lastCursorLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    // set variable for draggin
    //lastDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    lastDragLocation = [[[self window] contentView]convertPoint:[theEvent locationInWindow] toView:[self superview]];
}

- (void)mouseDownBySelection:(NSEvent *)theEvent{
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    [coreData getAllObjects];
    
    NSUInteger flags = [theEvent modifierFlags];
    //_savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
    _savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
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
    //lastCursorLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    lastCursorLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    // set variable for draggin
    //lastDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] toView:nil];
    lastDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
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
    //NSPoint newDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint newDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    NSPoint thisOrigin = [self frame].origin;
    NSLog(@"start origin: x:%f f:%f lastDragLocation:x:%f newDragLocation: x:%f", thisOrigin.x, thisOrigin.y, lastDragLocation.x, newDragLocation.x);
    // alter origin
    thisOrigin.x += (-lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-lastDragLocation.y + newDragLocation.y);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only do if we're snapping
    if ([defaults boolForKey:EDPreferenceSnapToGuides]) {
        float closestVerticalPointToOrigin, closestVerticalPointToEdge, closestHorizontalPointToOrigin, closestHorizontalPointToEdge;
        NSMutableDictionary *guides = [(EDWorksheetView *)[self superview] guides];
    NSLog(@"1: x:%f y:%f", thisOrigin.x, thisOrigin.y);
        
        // get vertical guide as long as there are guides to close enough
        if ([[guides objectForKey:EDKeyGuideVertical] count] > 0) {
            closestVerticalPointToOrigin = [self findClosestPoint:thisOrigin.y guides:[guides objectForKey:EDKeyGuideVertical]];
            closestVerticalPointToEdge = [self findClosestPoint:(thisOrigin.y + [[self dataObj] elementHeight]) guides:[guides objectForKey:EDKeyGuideVertical]];
            closestHorizontalPointToOrigin = [self findClosestPoint:thisOrigin.x guides:[guides objectForKey:EDKeyGuideHorizontal]];
            closestHorizontalPointToEdge = [self findClosestPoint:(thisOrigin.x + [[self dataObj] elementWidth]) guides:[guides objectForKey:EDKeyGuideHorizontal]];
        NSLog(@"2");
    NSLog(@"2: x:%f y:%f", thisOrigin.x, thisOrigin.y);
            
            
            // snap if edge of object is close to guide
            if ((fabsf(thisOrigin.y - closestVerticalPointToOrigin) < EDGuideThreshold) || 
                (fabsf((thisOrigin.y + [[self dataObj] elementHeight]) - closestVerticalPointToEdge) < EDGuideThreshold) || 
                (fabsf(thisOrigin.x - closestHorizontalPointToOrigin) < EDGuideThreshold) || 
                (fabsf((thisOrigin.x + [[self dataObj] elementWidth]) - closestHorizontalPointToEdge) < EDGuideThreshold)) {
                _didSnap = TRUE;
    NSLog(@"3: x:%f y:%f", thisOrigin.x, thisOrigin.y);
                
                // check snap to vertical point
                if (fabsf(thisOrigin.y - closestVerticalPointToOrigin) < EDGuideThreshold) {
                    thisOrigin.y = closestVerticalPointToOrigin;
                }
                else if (fabsf((thisOrigin.y + [[self dataObj] elementHeight]) - closestVerticalPointToEdge) < EDGuideThreshold) {
                    thisOrigin.y = closestVerticalPointToEdge - [[self dataObj] elementHeight];
                }
    NSLog(@"3.5: x:%f y:%f", thisOrigin.x, thisOrigin.y);
                
                // check snap to horizontal point
                if (fabsf(thisOrigin.x - closestHorizontalPointToOrigin) < EDGuideThreshold) {
                    thisOrigin.x = closestHorizontalPointToOrigin;
                }
                else if (fabsf((thisOrigin.x + [[self dataObj] elementWidth]) - closestHorizontalPointToEdge) < EDGuideThreshold) {
                    thisOrigin.x = closestHorizontalPointToEdge - [[self dataObj] elementWidth];
                }
    NSLog(@"4: x:%f y:%f", thisOrigin.x, thisOrigin.y);
            }
            else{
                if(_didSnap){
                    // reset
                    _didSnap = FALSE;
                    
                    // snap back to original location
                    //NSPoint currentLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
                    NSPoint currentLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
                    thisOrigin.y += (currentLocation.y - _savedMouseSnapLocation.y);
                    thisOrigin.x += (currentLocation.x - _savedMouseSnapLocation.x);
                }
            }
        }
        else{
            _didSnap = FALSE;
        }
    }
    
    NSLog(@"going to set origin x:%f y:%f", thisOrigin.x, thisOrigin.y);
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
