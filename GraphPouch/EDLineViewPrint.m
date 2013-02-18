//
//  EDLineViewPrint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDLine.h"
#import "EDLineViewPrint.h"

@implementation EDLineViewPrint

- (void)drawRect:(NSRect)dirtyRect
{
    // draw line in the middle of the bounds
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:[(EDLine *)[self dataObj] thickness]];
    [[NSColor blackColor] setStroke];
                        
    [path moveToPoint:NSMakePoint(0, [self bounds].size.height/2)];
    [path lineToPoint:NSMakePoint([self bounds].size.width, [self bounds].size.height/2)];
    
    [path stroke];
}
@end
