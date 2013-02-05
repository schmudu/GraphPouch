//
//  EDTextboxViewMask.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/2/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDTextboxViewMask.h"
#import "EDConstants.h"

@implementation EDTextboxViewMask

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
    [[NSColor redColor] setFill];
    [NSBezierPath fillRect:[self bounds]];
}

- (void)mouseDown:(NSEvent *)theEvent{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDown object:self];
    NSLog(@"mouse down mask.");
}
@end
