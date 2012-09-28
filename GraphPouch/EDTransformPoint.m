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
    
    NSLog(@"saved mouse lcoation: x:%f y:%f", _savedMouseSnapLocation.x, _savedMouseSnapLocation.y);
    // set variable for draggin
    _lastDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    [_nc postNotificationName:EDEventTransformMouseDown object:self];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint newDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    NSPoint thisOrigin = [self frame].origin;
    
    // alter origin
    thisOrigin.x += (-_lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-_lastDragLocation.y + newDragLocation.y);
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only do if we're snapping
    if ([defaults boolForKey:EDPreferenceSnapToGuides]) {
        float closestVerticalPointToOrigin, closestHorizontalPointToOrigin;
        NSMutableDictionary *guides = [(EDWorksheetView *)[[self superview] superview] guides];
        
        // get vertical guide as long as there are guides to close enough
        if ([[guides objectForKey:EDKeyGuideVertical] count] > 0) {
            closestVerticalPointToOrigin = [self findClosestPoint:thisOrigin.y guides:[guides objectForKey:EDKeyGuideVertical]];
            closestHorizontalPointToOrigin = [self findClosestPoint:thisOrigin.x guides:[guides objectForKey:EDKeyGuideHorizontal]];
            
            // snap if edge of object is close to guide
            if ((fabsf(thisOrigin.y - closestVerticalPointToOrigin) < EDGuideThreshold) || 
                (fabsf(thisOrigin.x - closestHorizontalPointToOrigin) < EDGuideThreshold)){ 
                _didSnap = TRUE;
                
                // check snap to vertical point
                if (fabsf(thisOrigin.y - closestVerticalPointToOrigin) < EDGuideThreshold) {
                    thisOrigin.y = closestVerticalPointToOrigin;
                }
                
                // check snap to horizontal point
                if (fabsf(thisOrigin.x - closestHorizontalPointToOrigin) < EDGuideThreshold) {
                    thisOrigin.x = closestHorizontalPointToOrigin;
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
