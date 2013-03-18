//
//  EDPageViewContainerLineCacheView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/18/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDPageViewContainerLineCacheView.h"

@implementation EDPageViewContainerLineCacheView

- (BOOL)isFlipped{
    return TRUE;
}

- (id)initWithFrame:(NSRect)frame lineImage:(NSImage *)lineImage;
{
    self = [super initWithFrame:frame];
    if (self) {
        _lineImage = lineImage;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_lineImage){
        NSRect imageRect = NSMakeRect(0, 0, [_lineImage size].width, [_lineImage size].height);
        [_lineImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0 respectFlipped:TRUE hints:nil];
    }
}

@end
