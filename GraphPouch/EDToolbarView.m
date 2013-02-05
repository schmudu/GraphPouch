//
//  EDToolbarView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/4/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

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

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSGradient *fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithHexColorString:@"dedede"] endingColor:[NSColor colorWithHexColorString:@"bbbbbb"]];
    // Create the path
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(0.0, 0.0)];
    [path lineToPoint:NSMakePoint([self bounds].size.width, 0.0)];
    [path lineToPoint:NSMakePoint([self bounds].size.width, [self bounds].size.height)];
    [path lineToPoint:NSMakePoint(0.0, [self bounds].size.height)];
    [path lineToPoint:NSMakePoint(0.0, 0.0)];
    [fillGradient drawInBezierPath:path angle:90.0];
}

@end
