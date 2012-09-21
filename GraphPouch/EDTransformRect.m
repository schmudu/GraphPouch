//
//  EDTransformRect.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDTransformRect.h"
#import "EDConstants.h"

@implementation EDTransformRect

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        topLeftPoint = [EDTransformPoint alloc];
        topRightPoint = [EDTransformPoint alloc];
        bottomLeftPoint = [EDTransformPoint alloc];
        bottomRightPoint = [EDTransformPoint alloc];
        
        [topLeftPoint initWithFrame:NSMakeRect(0, 0, EDTransformPointLength, EDTransformPointLength)];
        [topRightPoint initWithFrame:NSMakeRect([self frame].size.width - EDTransformPointLength, 0, EDTransformPointLength, EDTransformPointLength)];
        [bottomLeftPoint initWithFrame:NSMakeRect(0, [self frame].size.height - EDTransformPointLength, EDTransformPointLength, EDTransformPointLength)];
        [bottomRightPoint initWithFrame:NSMakeRect([self frame].size.width - EDTransformPointLength, [self frame].size.height - EDTransformPointLength, EDTransformPointLength, EDTransformPointLength)];
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if(![[self subviews] containsObject:topLeftPoint]){
        [self addSubview:topLeftPoint];
    }
    if(![[self subviews] containsObject:topRightPoint]){
        [self addSubview:topRightPoint];
    }
    if(![[self subviews] containsObject:bottomLeftPoint]){
        [self addSubview:bottomLeftPoint];
    }
    if(![[self subviews] containsObject:bottomRightPoint]){
        [self addSubview:bottomRightPoint];
    }
}
@end
