//
//  EDTransformCornerPointOnlyHorizontal.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDTransformCornerPointOnlyHorizontal.h"

@implementation EDTransformCornerPointOnlyHorizontal
#warning change here = change in EDTransformCornerPoint
- (id)initWithFrame:(NSRect)frame verticalPoint:(EDTransformCornerPointOnlyHorizontal *)newVerticalPoint horizPoint:(EDTransformCornerPointOnlyHorizontal *)newHorizPoint
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
