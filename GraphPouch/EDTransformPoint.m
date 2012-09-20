//
//  EDTransformPoint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDTransformPoint.h"

@implementation EDTransformPoint

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //NSBezierPath *aPath;
    //[aPath setLineWidth:2.0];
    NSLog(@"drawing point.");
    [[NSColor blueColor] set];
    //[NSBezierPath strokeRect:[self frame]];
    NSRectFill([self frame]);
}

@end
