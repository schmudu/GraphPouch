//
//  EDTransformRectHorizontalOnly.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDTransformRectOnlyHorizontal.h"
#import "EDTransformCornerPointOnlyHorizontal.h"

@implementation EDTransformRectOnlyHorizontal

- (id)initWithFrame:(NSRect)frame element:(EDElement *)element
{
    self = [super initWithFrame:frame];
    if (self) {
        topLeftPoint = [EDTransformCornerPointOnlyHorizontal alloc];
        topRightPoint = [EDTransformCornerPointOnlyHorizontal alloc];
        bottomLeftPoint = [EDTransformCornerPointOnlyHorizontal alloc];
        bottomRightPoint = [EDTransformCornerPointOnlyHorizontal alloc];
        
        // align element with data attributes
        topLeftPoint = [(EDTransformCornerPointOnlyHorizontal *)topLeftPoint initWithFrame:NSMakeRect([element locationX], [element locationY], EDTransformPointLength, EDTransformPointLength)
                      verticalPoint:(EDTransformCornerPointOnlyHorizontal *)topRightPoint
                         horizPoint:(EDTransformCornerPointOnlyHorizontal *)bottomLeftPoint];
        topRightPoint = [(EDTransformCornerPointOnlyHorizontal *)topRightPoint initWithFrame:NSMakeRect([element locationX] + [element elementWidth] - EDTransformPointLength, [element locationY], EDTransformPointLength, EDTransformPointLength)
                       verticalPoint:(EDTransformCornerPointOnlyHorizontal *)topLeftPoint
                          horizPoint:(EDTransformCornerPointOnlyHorizontal *)bottomRightPoint];
        bottomLeftPoint = [(EDTransformCornerPointOnlyHorizontal *)bottomLeftPoint initWithFrame:NSMakeRect([element locationX], [element locationY] + [element elementHeight] - EDTransformPointLength, EDTransformPointLength, EDTransformPointLength)
                         verticalPoint:(EDTransformCornerPointOnlyHorizontal *)bottomRightPoint
                            horizPoint:(EDTransformCornerPointOnlyHorizontal *)topLeftPoint];
        bottomRightPoint = [(EDTransformCornerPointOnlyHorizontal *)bottomRightPoint initWithFrame:NSMakeRect([element locationX] + [element elementWidth] - EDTransformPointLength, [element locationY] + [element elementHeight] - EDTransformPointLength, EDTransformPointLength, EDTransformPointLength)
                          verticalPoint:(EDTransformCornerPointOnlyHorizontal *)bottomLeftPoint
                             horizPoint:(EDTransformCornerPointOnlyHorizontal *)topRightPoint];
        // listen
        _nc = [NSNotificationCenter defaultCenter];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:topLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:topRightPoint];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:bottomLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:bottomRightPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseUp:) name:EDEventTransformMouseUp object:topLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseUp:) name:EDEventTransformMouseUp object:topRightPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseUp:) name:EDEventTransformMouseUp object:bottomLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseUp:) name:EDEventTransformMouseUp object:bottomRightPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseDown:) name:EDEventTransformMouseDown object:topLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseDown:) name:EDEventTransformMouseDown object:topRightPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseDown:) name:EDEventTransformMouseDown object:bottomLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseDown:) name:EDEventTransformMouseDown object:bottomRightPoint];
    }
    
    return self;
}
@end
