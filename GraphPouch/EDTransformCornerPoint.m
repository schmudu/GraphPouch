//
//  EDTransformCornerPoint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDTransformCornerPoint.h"
#import "EDConstants.h"

@interface EDTransformCornerPoint()
@end

@implementation EDTransformCornerPoint
#warning change here = change in EDTransformCornerPointOnlyHorizontal
- (id)initWithFrame:(NSRect)frame verticalPoint:(EDTransformCornerPoint *)newVerticalPoint horizPoint:(EDTransformCornerPoint *)newHorizPoint
{
    self = [super initWithFrame:frame];
    if (self) {
        horizontalPoint = newHorizPoint;
        verticalPoint = newVerticalPoint;
        
        // listen
        [_nc addObserver:self selector:@selector(onVerticalPointMoved:) name:EDEventTransformPointDragged object:verticalPoint];
        [_nc addObserver:self selector:@selector(onHorizontalPointMoved:) name:EDEventTransformPointDragged object:horizontalPoint];
    }
    
    return self;
}

- (void) dealloc{
    [_nc removeObserver:self name:EDEventTransformPointDragged object:verticalPoint];
    [_nc removeObserver:self name:EDEventTransformPointDragged object:horizontalPoint];
}

- (BOOL)isFlipped{
    return TRUE;
}

#pragma mark movement
- (void)onHorizontalPointMoved:(NSNotification *)note{
    // set frame horizontal position
    NSPoint thisOrigin = NSMakePoint([self frame].origin.x, [self frame].origin.y);
    thisOrigin.x = [[[note userInfo] valueForKey:@"locationX"] floatValue];
    [self setFrameOrigin:thisOrigin];
}

- (void)onVerticalPointMoved:(NSNotification *)note{
    // set frame horizontal position
    NSPoint thisOrigin = NSMakePoint([self frame].origin.x, [self frame].origin.y);
    thisOrigin.y = [[[note userInfo] valueForKey:@"locationY"] floatValue];
    [self setFrameOrigin:thisOrigin];
}
@end
