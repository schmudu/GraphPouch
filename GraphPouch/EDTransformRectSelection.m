//
//  EDTransformRectSelection.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/22/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDTransformRectSelection.h"
#import "NSColor+Utilities.h"

@implementation EDTransformRectSelection

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
    
    // draw selection
    [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:EDGraphSelectedBackgroundAlpha] set];
    [NSBezierPath fillRect:NSMakeRect([topLeftPoint frame].origin.x, [topLeftPoint frame].origin.y, [topRightPoint frame].origin.x - [topLeftPoint frame].origin.x + [topLeftPoint frame].size.width, [bottomLeftPoint frame].origin.y - [topLeftPoint frame].origin.y + [topLeftPoint frame].size.height)];
}

@end
