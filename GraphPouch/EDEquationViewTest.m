//
//  EDEquationViewTest.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/3/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDEquationViewTest.h"

@implementation EDEquationViewTest

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
    [[NSColor blueColor] setFill];
    [NSBezierPath fillRect:NSMakeRect(0, 0, 50, 50)];
}

@end
