//
//  EDTransformRect.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDTransformRect.h"

@implementation EDTransformRect

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
    NSLog(@"drawing transform rect.");
    // Drawing code here.
    //NSRect bounds = NSMakeRect(0, 0, [self bounds], [self bounds]);
    
    [[NSColor purpleColor] setFill];
    
    NSRectFill(dirtyRect);
}
@end
