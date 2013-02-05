//
//  EDToolbarView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/4/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDToolbarView.h"
#import "NSColor+Utilities.h"

@implementation EDToolbarView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

/*
- (BOOL)isFlipped{
    return TRUE;
}*/

- (void)drawRect:(NSRect)dirtyRect
{
    NSGradient *fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithHexColorString:@"dedede"] endingColor:[NSColor colorWithHexColorString:@"bbbbbb"]];
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(0.0, 0.0)];
    [path lineToPoint:NSMakePoint([self bounds].size.width, 0.0)];
    [path lineToPoint:NSMakePoint([self bounds].size.width, [self bounds].size.height)];
    [path lineToPoint:NSMakePoint(0.0, [self bounds].size.height)];
    [path lineToPoint:NSMakePoint(0.0, 0.0)];
    [fillGradient drawInBezierPath:path angle:270.0];
    
    NSGradient *dropShadowGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithHexColorString:@"999999"] endingColor:[NSColor colorWithHexColorString:@"aaaaaa"]];
    NSBezierPath *shadowPath = [NSBezierPath bezierPath];
 
    [shadowPath moveToPoint:NSMakePoint(0.0, EDMenuToolbarShadowWidth)];
    [shadowPath lineToPoint:NSMakePoint([self bounds].size.width, EDMenuToolbarShadowWidth)];
    [shadowPath lineToPoint:NSMakePoint([self bounds].size.width, 0.0)];
    [shadowPath lineToPoint:NSMakePoint(0.0, 0.0)];
    [shadowPath lineToPoint:NSMakePoint(0.0, EDMenuToolbarShadowWidth)];
    [dropShadowGradient drawInBezierPath:shadowPath angle:90.0];
}

@end
