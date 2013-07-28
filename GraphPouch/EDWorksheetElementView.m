//
//  EDWorksheetElementView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/26/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//
// testing
#import "EDGraphView.h"

#import "EDWorksheetView.h"
#import "EDElement.h"
#import "EDWorksheetElementView.h"
#import "EDConstants.h"
#import "EDGraph.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSManagedObject+Attributes.h"
#import "EDCoreDataUtility+Worksheet.h"
#import "EDCoreDataUtility+Pages.h"
#import "NSObject+Document.h"

@interface EDWorksheetElementView()
- (void)mouseUpBehavior:(NSEvent *)theEvent;
- (void)notifyMouseDownListeners:(NSEvent *)theEvent;
- (void)dispatchMouseDragNotification:(NSEvent *)theEvent snapInfo:(NSDictionary *)snapInfo;

// context menu
- (void)onMenuCommandCut:(NSNotification *)note;
- (void)onMenuCommandCopy:(NSNotification *)note;
- (void)onMenuCommandDelete:(NSNotification *)note;
- (void)onMenuCommandDeselect:(NSNotification *)note;
- (void)onMenuCommandSelect:(NSNotification *)note;
- (void)onMenuCommandMoveBack:(NSNotification *)note;
- (void)onMenuCommandMoveBackward:(NSNotification *)note;
- (void)onMenuCommandMoveForward:(NSNotification *)note;
- (void)onMenuCommandMoveFront:(NSNotification *)note;

// mouse drag
- (void)setZIndexToDragLayer;
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
        _mouseUpEventSource = FALSE;
        _savedZIndex = -1;
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

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent{
    return TRUE;
}

- (void)updateDisplayBasedOnContext{
    // update position
    [self setFrame:NSMakeRect([[[self dataObj] valueForKey:EDElementAttributeLocationX] floatValue],
                              [[[self dataObj] valueForKey:EDElementAttributeLocationY] floatValue],
                              [[[self dataObj] valueForKey:EDElementAttributeWidth] floatValue],
                              [[[self dataObj] valueForKey:EDElementAttributeHeight] floatValue])];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventWorksheetElementRedrawingItself object:self];
    //[self setNeedsDisplay:TRUE];
    [self setNeedsDisplayInRect:NSMakeRect(0, 0, [(EDElement *)[self dataObj] elementWidth], [(EDElement *)[self dataObj] elementWidth])];
}

#pragma mark drawing
- (void)removeFeatures{
    // method called to remove performance-heavy elements
    // useful during mouse dragging
    //NSLog(@"remove elements.");
    
    /*
    // TESTING
    // add drag helper when removing features
    _dragView = [[NSView alloc] initWithFrame:NSMakeRect(-40, -40, [self bounds].size.width+80, [self bounds].size.height+80)];
    [self addSubview:_dragView];
    [_dragView lockFocus];
    [[NSColor redColor] setFill];
    [NSBezierPath fillRect:[_dragView bounds]];
    [_dragView unlockFocus];
    */
}

- (void)addFeatures{
    
    // TESTING
    //[_dragView removeFromSuperview];
    
    // method called to add performance-heavy elements
    // useful after mouse dragging has completed
    //NSLog(@"add elements.");
}

#pragma mark context menu
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    if ([[menuItem title] isEqualToString:EDContextMenuElementSelect]){
        if ([(EDElement *)[self dataObj] selected])
            return FALSE;
        else
            return TRUE;
    }
    
    if ([[menuItem title] isEqualToString:EDContextMenuElementDeselect]){
        if ([(EDElement *)[self dataObj] selected])
            return TRUE;
        else
            return FALSE;
    }
    
    if (([[menuItem title] isEqualToString:EDContextMenuElementCopy]) ||
        ([[menuItem title] isEqualToString:EDContextMenuElementCut]) ||
        ([[menuItem title] isEqualToString:EDContextMenuElementDelete]) ||
        ([[menuItem title] isEqualToString:EDContextMenuElementMoveBack]) ||
        ([[menuItem title] isEqualToString:EDContextMenuElementMoveBackward]) ||
        ([[menuItem title] isEqualToString:EDContextMenuElementMoveForward]) ||
        ([[menuItem title] isEqualToString:EDContextMenuOrderTitle]) ||
        ([[menuItem title] isEqualToString:EDContextMenuElementMoveFront])){
        return TRUE;
    }
    
    return [super validateMenuItem:menuItem];
}

- (NSMenu *)menuForEvent:(NSEvent *)event{
    NSMenu *returnMenu = [[NSMenu alloc] init];
    [returnMenu addItemWithTitle:EDContextMenuElementSelect action:@selector(onMenuCommandSelect:) keyEquivalent:@""];
    [returnMenu addItemWithTitle:EDContextMenuElementDeselect action:@selector(onMenuCommandDeselect:) keyEquivalent:@""];
    [returnMenu addItem:[NSMenuItem separatorItem]];
    [returnMenu addItemWithTitle:EDContextMenuElementCopy action:@selector(onMenuCommandCopy:) keyEquivalent:@""];
    [returnMenu addItemWithTitle:EDContextMenuElementCut action:@selector(onMenuCommandCut:) keyEquivalent:@""];
    [returnMenu addItemWithTitle:EDContextMenuElementDelete action:@selector(onMenuCommandDelete:) keyEquivalent:@""];
    [returnMenu addItem:[NSMenuItem separatorItem]];
    
    // reorder element
    NSMenu *arrangeMenu = [[NSMenu alloc] initWithTitle:@"arrange menu"];
    NSMenuItem *arrangeMenuItem = [[NSMenuItem alloc] initWithTitle:EDContextMenuOrderTitle action:nil keyEquivalent:@""];
    [arrangeMenu addItemWithTitle:EDContextMenuElementMoveFront action:@selector(onMenuCommandMoveFront:) keyEquivalent:@""];
    [arrangeMenu addItemWithTitle:EDContextMenuElementMoveForward action:@selector(onMenuCommandMoveForward:) keyEquivalent:@""];
    [arrangeMenu addItemWithTitle:EDContextMenuElementMoveBackward action:@selector(onMenuCommandMoveBackward:) keyEquivalent:@""];
    [arrangeMenu addItemWithTitle:EDContextMenuElementMoveBack action:@selector(onMenuCommandMoveBack:) keyEquivalent:@""];
    [arrangeMenuItem setSubmenu:arrangeMenu];
    
    [returnMenu addItem:arrangeMenuItem];
    
    return returnMenu;
}

#pragma mark reorder
- (void)onMenuCommandMoveBack:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventResetZIndices object:self];
    EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
    [(EDElement *)[self dataObj] moveZIndexBack:page];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventCheckElementLayers object:self];
}

- (void)onMenuCommandMoveBackward:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventResetZIndices object:self];
    EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
    [(EDElement *)[self dataObj] moveZIndexBackward:page];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventCheckElementLayers object:self];
}

- (void)onMenuCommandMoveForward:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventResetZIndices object:self];
    EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
    [(EDElement *)[self dataObj] moveZIndexForward:page];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventCheckElementLayers object:self];
}

- (void)onMenuCommandMoveFront:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventResetZIndices object:self];
    EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
    [(EDElement *)[self dataObj] moveZIndexFront:page];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventCheckElementLayers object:self];
}

- (void)onMenuCommandCut:(NSNotification *)note{
    NSArray *object = [NSArray arrayWithObject:[self dataObj]];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:object];
    
    [EDCoreDataUtility deleteWorksheetElement:[self dataObj] context:_context];
}

- (void)onMenuCommandCopy:(NSNotification *)note{
    NSArray *object = [NSArray arrayWithObject:[self dataObj]];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:object];
}

- (void)onMenuCommandDelete:(NSNotification *)note{
    [EDCoreDataUtility deleteWorksheetElement:[self dataObj] context:_context];
}

- (void)onMenuCommandDeselect:(NSNotification *)note{
   // deselect element
    [(EDElement *)[self dataObj] setSelected:FALSE];
}

- (void)onMenuCommandSelect:(NSNotification *)note{
   // select element
    [(EDElement *)[self dataObj] setSelected:TRUE];
}

#pragma mark mouse events
- (void)setZIndexToDragLayer{
    //NSLog(@"setting z-index: current:%d", [[(EDElement *)[self dataObj] zIndex] intValue]);
    // save z-index, do not save if max value or greater
    if ([[(EDElement *)[self dataObj] zIndex] intValue] < EDLayerZIndexMax) {
        // reset z-indices
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventResetZIndices object:self];
        
        _savedZIndex = [[(EDElement *)[self dataObj] zIndex] intValue];
        //NSLog(@"going to save z index as:%d for class:%@", [[(EDElement *)[self dataObj] zIndex] intValue], [(EDElement *)[self dataObj] class]);
    }
    
    // set z-index so that element is in front
    [(EDElement *)[self dataObj] setZIndex:[NSNumber numberWithInt:EDLayerZIndexMax]];
    
    // set layers to their new positions
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventCheckElementLayers object:self];
}

//- (void)unsetZIndexFromDragLayer{
- (void)unsetZIndexFromDragLayer:(BOOL)updateStage{
    // reset z-index to its original value
    if ((_savedZIndex != -1) && (_savedZIndex < EDLayerZIndexMax)){
        //NSLog(@"restoring z index as:%d from index:%d for class:%@", _savedZIndex, [[(EDElement *)[self dataObj] zIndex] intValue], [(EDElement *)[self dataObj] class]);
        [(EDElement *)[self dataObj] setZIndex:[NSNumber numberWithInt:_savedZIndex]];
        
        // set layers to their original positions
        if (updateStage)
            [[NSNotificationCenter defaultCenter] postNotificationName:EDEventCheckElementLayers object:self];
    }
    
    // reset to original value
    _savedZIndex = -1;
}

- (void)mouseDown:(NSEvent *)theEvent{
    // reset z-index
    [self setZIndexToDragLayer];
    
#warning CAREFUL: SOME code you change here needs to change in the "mouseDownBySelection" method
    NSUInteger flags = [theEvent modifierFlags];
    if(flags & NSControlKeyMask){
        // do nothing so menu can show up
        [self rightMouseDown:theEvent];
    }
    
    // set worksheet view as getAllSelectedWorksheetElements
    [[self window] makeFirstResponder:[self superview]];
 
    //save mouse location
    _savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
    NSLog(@"setting saved mouse snap location to:%f", _savedMouseSnapLocation.y);
    _didSnap = FALSE;
    
    if ([[self dataObj] isSelectedElement]){
        // graph is already selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDElementAttributeSelected];
        }
        else{
        }
    } else {
        // graph is not selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
        }
        else {
            NSMutableDictionary *clickInfo = [[NSMutableDictionary alloc] init];
            [clickInfo setObject:[self dataObj] forKey:EDKeyWorksheetElement];
            
            // post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:EDEventUnselectedElementClickedWithoutModifier object:self userInfo:clickInfo];
        }
    }
    
    [self notifyMouseDownListeners:theEvent];
    
    // set variable for dragging
    _lastCursorLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    // set variable for dragging
    _lastDragLocation = [[[self window] contentView]convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    // if mouse up already then we need to catch it and call it's behavior
    NSEvent *nextEvent = [[self window] nextEventMatchingMask:NSLeftMouseUpMask untilDate:[[NSDate date] dateByAddingTimeInterval:0.1] inMode:NSDefaultRunLoopMode dequeue:NO];
    if ([nextEvent type] == NSLeftMouseUp){
        // unset z-index
        [self unsetZIndexFromDragLayer:TRUE];
        
        // special case because mouseUp is not called
        [self removeFeatures];
        //[self mouseUp:theEvent];
        // special case
        // notify listeners of mouse up that wouldn't be registered by normal mouse up
        NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
        [notificationDictionary setValue:theEvent forKey:EDEventKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseUp object:self userInfo:notificationDictionary];
     }
}

- (void)mouseDownBySelection:(NSEvent *)theEvent{
    _savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
    
    // set variable for dragging
    _lastCursorLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    // set variable for draggin
    _lastDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
}

- (void)notifyMouseDownListeners:(NSEvent *)theEvent{
    // notify listeners of mouse down
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    [notificationDictionary setValue:theEvent forKey:EDEventKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDown object:self userInfo:notificationDictionary];
}

#pragma mark mouse dragged
- (void)mouseDragged:(NSEvent *)theEvent{
    // on mouse drag elements that are above interfere with the dragging
    // so we are going to send this element to the font and then return it to its origin z-index
    // do not drag if it is not selected
    if (![(EDElement *)[self dataObj] isSelectedElement]){
        // notify listeners of mouse drag over unselected element
        NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
        [notificationDictionary setObject:theEvent forKey:EDKeyEvent];
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDraggedOverUnselectedElement object:self userInfo:notificationDictionary];
        return;
    }
    
    BOOL didSnapX = FALSE, didSnapY = FALSE, didSnapBack = FALSE;
    
    // remove performance heavy elements
    [self removeFeatures];
    
    // check 
    NSPoint newDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    float snapDistanceY=0, snapDistanceX = 0;
    float snapBackDistanceY=0, snapBackDistanceX = 0;
    NSPoint thisOrigin = [self frame].origin;
    NSPoint savedOrigin = [self frame].origin;
    
    thisOrigin.x += (-_lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-_lastDragLocation.y + newDragLocation.y);
    
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
                    thisOrigin.y = (newDragLocation.y - _savedMouseSnapLocation.y);
                    thisOrigin.x = (newDragLocation.x - _savedMouseSnapLocation.x);
                    
#warning check out snap by distance with multiple elements selected
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
    //NSLog(@"setting frame origin to:%@", NSStringFromPoint(thisOrigin));
    _lastDragLocation = newDragLocation;
    
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
            thisOrigin.x += (-_lastDragLocation.x + newDragLocation.x);
        }
        else {
            thisOrigin.x -= [[snapInfo valueForKey:EDKeySnapDistanceX] floatValue];
        }
        
        if (!originalSourceSnapY) {
            thisOrigin.y += (-_lastDragLocation.y + newDragLocation.y);
        }
        else {
            thisOrigin.y -= [[snapInfo valueForKey:EDKeySnapDistanceY] floatValue];
        }
    }
    
    [self setFrameOrigin:thisOrigin];
    _lastDragLocation = newDragLocation;
}

#pragma mark mouse up
- (void)mouseUp:(NSEvent *)theEvent{
    // unset z-index
    [self unsetZIndexFromDragLayer:TRUE];
    
    [self mouseUpBehavior:theEvent];
    
    // add performance heavy elements that were removed during dragging
    [self addFeatures];
    
    // this was the event origin
    _mouseUpEventSource = TRUE;
    
    // notify listeners
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    [notificationDictionary setValue:theEvent forKey:EDEventKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseUp object:self userInfo:notificationDictionary];
}

- (void)mouseUpBySelection:(NSEvent *)theEvent{
    // if this was the source then do not add the features again
    if(!_mouseUpEventSource){
        // add performance heavy elements that were removed during dragging
        [self addFeatures];
    }
    else{
        _mouseUpEventSource = FALSE;
    }
    
    [self mouseUpBehavior:theEvent];
}

- (void)mouseUpBehavior:(NSEvent *)theEvent{
    float diffY = fabsf(_lastCursorLocation.y - _lastDragLocation.y);
    float diffX = fabsf(_lastCursorLocation.x - _lastDragLocation.x);
    
    //if no diff in location than do not prepare an undo
    if(fabsf(diffX>0.01) && fabsf(diffY>0.01)){
        NSNumber *valueX = [[NSNumber alloc] initWithFloat:[self frame].origin.x];
        NSNumber *valueY = [[NSNumber alloc] initWithFloat:[self frame].origin.y];
        [[self dataObj] setValue:valueX forKey:EDElementAttributeLocationX];
        [[self dataObj] setValue:valueY forKey:EDElementAttributeLocationY];
        
        // this fixes bug of dragging an element and deselecting the element
        // and it dragging to its origin position
        // save
        [EDCoreDataUtility saveContext:_context];
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
    //[self setNeedsDisplay:TRUE];
    [self setNeedsDisplayInRect:NSMakeRect(0, 0, [(EDElement *)[self dataObj] elementWidth], [(EDElement *)[self dataObj] elementWidth])];
}

- (void)onWorksheetSelectedElementRemoved:(NSNotification *)note{
    //[self setNeedsDisplay:TRUE];
    [self setNeedsDisplayInRect:NSMakeRect(0, 0, [(EDElement *)[self dataObj] elementWidth], [(EDElement *)[self dataObj] elementWidth])];
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
