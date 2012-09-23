//
//  EDTransformCornerPoint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDTransformCornerPoint.h"

@implementation EDTransformCornerPoint

- (id)initWithFrame:(NSRect)frame verticalPoint:(EDTransformCornerPoint *)newVerticalPoint horizPoint:(EDTransformCornerPoint *)newHorizPoint
{
    self = [super initWithFrame:frame];
    if (self) {
        horizontalPoint = newHorizPoint;
        verticalPoint = newVerticalPoint;
        
        // listen
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
