//
//  EDTransformPoint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDTransformPoint.h"
#import "EDConstants.h"
#import "EDWorksheetView.h"
@interface EDTransformPoint()
- (float)findClosestPoint:(float)currentPoint guides:(NSMutableArray *)guides;
@end

@implementation EDTransformPoint

@synthesize transformCorner;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mouseIsOver = FALSE;
        
        _nc = [NSNotificationCenter defaultCenter];
        
        // add tracking area
        [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds] options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil]];
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blueColor] set];
    if(_mouseIsOver){
        [NSBezierPath fillRect:[self bounds]];
    }
    else {
        [NSBezierPath strokeRect:[self bounds]];
    }
}

#pragma mark mouse
- (void)mouseEntered:(NSEvent *)theEvent{
    _mouseIsOver = TRUE;
    [self setNeedsDisplay:TRUE];
}

- (void)mouseExited:(NSEvent *)theEvent{
    _mouseIsOver = FALSE;
    [self setNeedsDisplay:TRUE];
}

- (void)mouseDown:(NSEvent *)theEvent{
    // set variable for dragging
    _lastCursorLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    // save mouse location
    _savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
    
    // set variable for draggin
    _lastDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    [_nc postNotificationName:EDEventTransformMouseDown object:self];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint newDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
#warning once we figure out which corner, we need to set this point to the correct origin
    NSLog(@"which corner?%@", [self transformCorner]);
    NSPoint thisOrigin = [self frame].origin;
    
        
    // alter origin
    thisOrigin.x += (-_lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-_lastDragLocation.y + newDragLocation.y);
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only do if we're snapping
    if ([defaults boolForKey:EDPreferenceSnapToGuides]) {
        float horizontalGuideModifer = 0, verticalGuideModifier = 0;
        float closestVerticalPointToOrigin, closestHorizontalPointToOrigin, modifiedPosY, modifiedPosX;
        NSMutableDictionary *guides = [(EDWorksheetView *)[[self superview] superview] guides];
        
        // figure out modifiers
        // this is because the origin is always the upper left however the point may be in another corner
        // so the guides must reflect that
        if ([[self transformCorner] isEqualToString:EDTransformCornerBottomLeft])
            verticalGuideModifier = EDTransformPointLength;
        else if ([[self transformCorner] isEqualToString:EDTransformCornerUpperRight]) 
            horizontalGuideModifer = EDTransformPointLength;
        else if ([[self transformCorner] isEqualToString:EDTransformCornerBottomRight]) {
            horizontalGuideModifer = EDTransformPointLength;
            verticalGuideModifier = EDTransformPointLength;
        }
        
        modifiedPosX = thisOrigin.x + horizontalGuideModifer;
        modifiedPosY = thisOrigin.y + verticalGuideModifier;
        
        // get vertical guide as long as there are guides to close enough
        if ([[guides objectForKey:EDKeyGuideVertical] count] > 0) {
            closestVerticalPointToOrigin = [self findClosestPoint:modifiedPosY guides:[guides objectForKey:EDKeyGuideVertical]];
            closestHorizontalPointToOrigin = [self findClosestPoint:modifiedPosX guides:[guides objectForKey:EDKeyGuideHorizontal]];
            
            // snap if edge of object is close to guide
            if ((fabsf(modifiedPosY - closestVerticalPointToOrigin) < EDGuideThreshold) || 
                (fabsf(modifiedPosX - closestHorizontalPointToOrigin) < EDGuideThreshold)){ 
                _didSnap = TRUE;
                
                // check snap to vertical point
                if (fabsf(modifiedPosY - closestVerticalPointToOrigin) < EDGuideThreshold) {
                    // snap to new position plus the modifier
                    thisOrigin.y = closestVerticalPointToOrigin - verticalGuideModifier;
                }
                
                // check snap to horizontal point
                if (fabsf(modifiedPosX - closestHorizontalPointToOrigin) < EDGuideThreshold) {
                    // snap to new position plus the modifier
                    thisOrigin.x = closestHorizontalPointToOrigin - horizontalGuideModifer;
                }
            }
            else{
                if(_didSnap){
                    // reset
                    _didSnap = FALSE;
                    
                    // snap back to original location
                    NSPoint currentLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
                    thisOrigin.y += (currentLocation.y - _savedMouseSnapLocation.y);
                    thisOrigin.x += (currentLocation.x - _savedMouseSnapLocation.x);
                }
            }
        }
        else{
            _didSnap = FALSE;
        }
    }
 
    [self setFrameOrigin:thisOrigin];
    _lastDragLocation = newDragLocation;
    
    // dispatch event
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    [infoDic setValue:[[NSNumber alloc] initWithFloat:thisOrigin.x] forKey:@"locationX"];
    [infoDic setValue:[[NSNumber alloc] initWithFloat:thisOrigin.y] forKey:@"locationY"];
    [_nc postNotificationName:EDEventTransformPointDragged object:self userInfo:infoDic];
}

- (void)mouseUp:(NSEvent *)theEvent{
    [super mouseUp:theEvent];
    
    [_nc postNotificationName:EDEventTransformMouseUp object:self];
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
