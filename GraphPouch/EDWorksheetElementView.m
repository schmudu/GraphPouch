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
#import "EDCoreDataUtility+Worksheet.h"
#import "NSObject+Document.h"

@interface EDWorksheetElementView()
- (void)mouseUpBehavior:(NSEvent *)theEvent;
- (void)notifyMouseDownListeners:(NSEvent *)theEvent;
- (void)dispatchMouseDragNotification:(NSEvent *)theEvent snapInfo:(NSDictionary *)snapInfo;
@end

@implementation EDWorksheetElementView
@synthesize dataObj;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _didSnapToSourceX = FALSE;
        _didSnapToSourceY = FALSE;
        
    }
    
    return self;
}

- (void)dealloc{
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)drawElementAttributes{
    
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

#pragma mark drawing
- (void)removeFeatures{
    // method called to remove performance-heavy elements
    // useful during mouse dragging
    //NSLog(@"remove elements.");
}

- (void)addFeatures{
    // method called to add performance-heavy elements
    // useful after mouse dragging has completed
    //NSLog(@"add elements.");
}

#pragma mark mouse events
#pragma mark mouse down
- (void)mouseDown:(NSEvent *)theEvent{
#warning CAREFUL: SOME code you change here needs to change in the "mouseDownBySelection" method
     // set worksheet view as getAllSelectedWorksheetElements
    [[self window] makeFirstResponder:[self superview]];
    
    NSUInteger flags = [theEvent modifierFlags];
 
    //save mouse location
    _savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:EDEventUnselectedElementClickedWithoutModifier object:self];
            
            //need to deselect all the other graphs
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
            
            [self notifyMouseDownListeners:theEvent];
        }
    }
    
    // set variable for dragging
    lastCursorLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    // set variable for draggin
    lastDragLocation = [[[self window] contentView]convertPoint:[theEvent locationInWindow] toView:[self superview]];
}

- (void)mouseDownBySelection:(NSEvent *)theEvent{
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
            [[NSNotificationCenter defaultCenter] postNotificationName:EDEventUnselectedElementClickedWithoutModifier object:self];
            
            //need to deselect all the other graphs
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
        }
    }
    
    // set variable for dragging
    lastCursorLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    // set variable for draggin
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
    // do not drag if it is not selected
    if (![(EDGraph *)[self dataObj] isSelectedElement]) 
        return;
        
    BOOL didSnapX = FALSE, didSnapY = FALSE, didSnapBack = FALSE;
    
    // remove performance heavy elements
    [self removeFeatures];
    
    // check 
    NSPoint newDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    float snapDistanceY=0, snapDistanceX = 0;
    float snapBackDistanceY=0, snapBackDistanceX = 0;
    NSPoint thisOrigin = [self frame].origin;
    NSPoint savedOrigin = [self frame].origin;
    
    thisOrigin.x += (-lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-lastDragLocation.y + newDragLocation.y);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only do if we're snapping
    if ([defaults boolForKey:EDPreferenceSnapToGuides]) {
        float closestVerticalPointToOrigin, closestVerticalPointToEdge, closestHorizontalPointToOrigin, closestHorizontalPointToEdge;
        NSMutableDictionary *guides = [(EDWorksheetView *)[self superview] guides];
        
        // get vertical guide as long as there are guides to close enough
        // only allow the drag source to snap to guides
        if ([[guides objectForKey:EDKeyGuideVertical] count] > 0) {
            closestVerticalPointToOrigin = [self findClosestPoint:thisOrigin.y guides:[guides objectForKey:EDKeyGuideVertical]];
            closestVerticalPointToEdge = [self findClosestPoint:(thisOrigin.y + [[self dataObj] elementHeight]) guides:[guides objectForKey:EDKeyGuideVertical]];
            closestHorizontalPointToOrigin = [self findClosestPoint:thisOrigin.x guides:[guides objectForKey:EDKeyGuideHorizontal]];
            closestHorizontalPointToEdge = [self findClosestPoint:(thisOrigin.x + [[self dataObj] elementWidth]) guides:[guides objectForKey:EDKeyGuideHorizontal]];
            
            
            // snap if edge of object is close to guide
            if ((fabsf(thisOrigin.y - closestVerticalPointToOrigin) < EDGuideThreshold) || 
                (fabsf((thisOrigin.y + [[self dataObj] elementHeight]) - closestVerticalPointToEdge) < EDGuideThreshold) || 
                (fabsf(thisOrigin.x - closestHorizontalPointToOrigin) < EDGuideThreshold) || 
                (fabsf((thisOrigin.x + [[self dataObj] elementWidth]) - closestHorizontalPointToEdge) < EDGuideThreshold)) {
                _didSnap = TRUE;
                
                // check snap to vertical point
                if (fabsf(thisOrigin.y - closestVerticalPointToOrigin) < EDGuideThreshold) {
                    snapDistanceY = savedOrigin.y - closestVerticalPointToOrigin;
                    thisOrigin.y = closestVerticalPointToOrigin;
                    didSnapY = TRUE;
                }
                else if (fabsf((thisOrigin.y + [[self dataObj] elementHeight]) - closestVerticalPointToEdge) < EDGuideThreshold) {
                    //NSLog(@"case 2");
                    thisOrigin.y = closestVerticalPointToEdge - [[self dataObj] elementHeight];
                    snapDistanceY = savedOrigin.y + [[self dataObj] elementHeight] - closestVerticalPointToEdge;
                    didSnapY = TRUE;
                }
                
                // check snap to horizontal point
                if (fabsf(thisOrigin.x - closestHorizontalPointToOrigin) < EDGuideThreshold) {
                    thisOrigin.x = closestHorizontalPointToOrigin;
                    snapDistanceX = savedOrigin.x - closestHorizontalPointToOrigin;
                    didSnapX = TRUE;
                }
                else if (fabsf((thisOrigin.x + [[self dataObj] elementWidth]) - closestHorizontalPointToEdge) < EDGuideThreshold) {
                    thisOrigin.x = closestHorizontalPointToEdge - [[self dataObj] elementWidth];
                    snapDistanceX = (savedOrigin.x + [[self dataObj] elementWidth]) - closestHorizontalPointToEdge;
                    didSnapX = TRUE;
                }
            }
            else{
                if(_didSnap){
                    // reset
                    _didSnap = FALSE;
                    didSnapBack = TRUE;
                    
                    // snap back to original location
                    NSPoint currentLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
                    thisOrigin.y += (currentLocation.y - _savedMouseSnapLocation.y);
                    thisOrigin.x += (currentLocation.x - _savedMouseSnapLocation.x);
                    
                    snapBackDistanceY = (savedOrigin.y - thisOrigin.y);
                    snapBackDistanceX = (savedOrigin.x - thisOrigin.x);
                }
            }
        }
        else{
            _didSnap = FALSE;
        }
    }
    
    [self setFrameOrigin:thisOrigin];
    lastDragLocation = newDragLocation;
    
    // dispatch event if drag source
    if (_didSnap) {
        // if source did snap then notify listeners
        NSMutableDictionary *snapInfo = [[NSMutableDictionary alloc] init];
        [snapInfo setValue:[[NSNumber alloc] initWithBool:didSnapX] forKey:EDKeyDidSnapX];
        [snapInfo setValue:[[NSNumber alloc] initWithFloat:snapDistanceX] forKey:EDKeySnapDistanceX];
        [snapInfo setValue:[[NSNumber alloc] initWithBool:didSnapY] forKey:EDKeyDidSnapY];
        [snapInfo setValue:[[NSNumber alloc] initWithFloat:snapDistanceY] forKey:EDKeySnapDistanceY];
        [self dispatchMouseDragNotification:theEvent snapInfo:snapInfo];
    }
    else {
        if (didSnapBack) {
            // notify listeners that we snapped back
            NSMutableDictionary *snapInfo = [[NSMutableDictionary alloc] init];
            [snapInfo setValue:[[NSNumber alloc] initWithBool:didSnapBack] forKey:EDKeyDidSnapBack];
            [snapInfo setValue:[[NSNumber alloc] initWithFloat:snapBackDistanceY] forKey:EDKeySnapBackDistanceY];
            [snapInfo setValue:[[NSNumber alloc] initWithFloat:snapBackDistanceX] forKey:EDKeySnapBackDistanceX];
            [self dispatchMouseDragNotification:theEvent snapInfo:snapInfo];
         }
        else{
            [self dispatchMouseDragNotification:theEvent snapInfo:nil];
        }
    }
}

- (void)dispatchMouseDragNotification:(NSEvent *)theEvent snapInfo:(NSDictionary *)snapInfo{
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    [notificationDictionary setValue:theEvent forKey:EDEventKey];
    
    // if there is snap info
    if (snapInfo) {
        [notificationDictionary setValue:snapInfo forKey:EDKeySnapInfo];
    }
    
    [notificationDictionary setValue:theEvent forKey:EDEventKey];
    [notificationDictionary setValue:self forKey:EDKeyWorksheetElement];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDragged object:self userInfo:notificationDictionary];
}

- (void)mouseDraggedBySelection:(NSEvent *)theEvent snapInfo:(NSDictionary *)snapInfo{
    BOOL originalSourceSnapX = [[snapInfo valueForKey:EDKeyDidSnapX] boolValue];
    BOOL originalSourceSnapY = [[snapInfo valueForKey:EDKeyDidSnapY] boolValue];
    BOOL originalSourceDidSnapBack = [[snapInfo valueForKey:EDKeyDidSnapBack] boolValue];
    // if not drag source then maybe we don't need to move this!
    // check 
    NSPoint newDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    NSPoint thisOrigin = [self frame].origin;
    
    // remove performance heavy elements
    [self removeFeatures];
    
    // if original source did snap back then modify location by that distance
    if (originalSourceDidSnapBack){
        thisOrigin.y -= [[snapInfo valueForKey:EDKeySnapBackDistanceY] floatValue];
        thisOrigin.x -= [[snapInfo valueForKey:EDKeySnapBackDistanceX] floatValue];
    }
    else{
        if (!originalSourceSnapX) {
            thisOrigin.x += (-lastDragLocation.x + newDragLocation.x);
        }
        else {
            thisOrigin.x -= [[snapInfo valueForKey:EDKeySnapDistanceX] floatValue];
        }
        
        if (!originalSourceSnapY) {
            thisOrigin.y += (-lastDragLocation.y + newDragLocation.y);
        }
        else {
            thisOrigin.y -= [[snapInfo valueForKey:EDKeySnapDistanceY] floatValue];
        }
    }
    
    [self setFrameOrigin:thisOrigin];
    lastDragLocation = newDragLocation;
}

#pragma mark mouse up
- (void)mouseUp:(NSEvent *)theEvent{
    [self mouseUpBehavior:theEvent];
    
    // add performance heavy elements that were removed during dragging
    [self addFeatures];
    
    // notify listeners
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    [notificationDictionary setValue:theEvent forKey:EDEventKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseUp object:self userInfo:notificationDictionary];
}

- (void)mouseUpBySelection:(NSEvent *)theEvent{
    // add performance heavy elements that were removed during dragging
    [self addFeatures];
    
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
    NSManagedObject *element;
    
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
    float smallestDiff = EDNumberMax;
    float closestPoint = 0;
    
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
