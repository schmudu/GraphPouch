//
//  EDEquationView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/2/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDEquationView.h"

@implementation EDEquationView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor redColor] set];
    //NSLog(@"drawing equation view.");
    //[NSBezierPath fillRect:[self frame]];
    [NSBezierPath fillRect:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height)];
    NSLog(@"frame: x:%f y:%f width:%f", [self frame].origin.x, [self frame].origin.y, [self frame].size.width);
}

@end
