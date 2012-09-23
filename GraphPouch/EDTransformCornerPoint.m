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

- (id)initWithFrame:(NSRect)frame verticalPoint:(EDTransformCornerPoint *)newVerticalPoint horizPoint:(EDTransformCornerPoint *)newHorizPoint
{
    self = [super initWithFrame:frame];
    if (self) {
        horizontalPoint = newHorizPoint;
        verticalPoint = newVerticalPoint;
        
        // listen
        [_nc addObserver:self selector:@selector(onVerticalPointMoved:) name:EDEventTransformPointMoved object:verticalPoint];
        [_nc addObserver:self selector:@selector(onHorizontalPointMoved:) name:EDEventTransformPointMoved object:horizontalPoint];
    }
    
    return self;
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
