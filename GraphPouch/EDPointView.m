//
//  EDPointView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/14/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPointView.h"
#import "EDConstants.h"

@implementation EDPointView

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
    [[NSColor blackColor] setFill];
    NSBezierPath *path;
    path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height)];
    [path fill];
}

@end
