//
//  EDEquationCacheView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/6/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDEquationCacheView.h"

@implementation EDEquationCacheView


- (id)initWithFrame:(NSRect)frame equationImage:(NSImage *)equationImage
{
    self = [super initWithFrame:frame];
    if (self) {
        _equationImage = equationImage;
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_equationImage){
        NSRect imageRect = NSMakeRect(0, 0, [_equationImage size].width, [_equationImage size].height);
        [_equationImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0 respectFlipped:TRUE hints:nil];
    }
}

@end
