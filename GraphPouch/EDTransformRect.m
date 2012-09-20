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
        topLeftPoint = [[EDTransformPoint alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)];
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSLog(@"drawing rect.");
    // Drawing code here.
    //NSRect bounds = NSMakeRect(0, 0, [self bounds], [self bounds]);
    
    //[[NSColor purpleColor] setFill];
    
    //NSRectFill(dirtyRect);
    
    if(![[self subviews] containsObject:topLeftPoint]){
        [self addSubview:topLeftPoint];
    }
}
@end
