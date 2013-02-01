//
//  EDTransformPointOnlyHorizontal.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDTransformPointOnlyHorizontal.h"
#import "EDWorksheetView.h"

@implementation EDTransformPointOnlyHorizontal

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint newDragLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    NSPoint thisOrigin = [self frame].origin;
        
    // alter origin
    thisOrigin.x += (-_lastDragLocation.x + newDragLocation.x);
    //thisOrigin.y += (-_lastDragLocation.y + newDragLocation.y);
    
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
                /*
                if (fabsf(modifiedPosY - closestVerticalPointToOrigin) < EDGuideThreshold) {
                    // snap to new position plus the modifier
                    thisOrigin.y = closestVerticalPointToOrigin - verticalGuideModifier;
                }*/
                
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
                    //thisOrigin.y += (currentLocation.y - _savedMouseSnapLocation.y);
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
@end
