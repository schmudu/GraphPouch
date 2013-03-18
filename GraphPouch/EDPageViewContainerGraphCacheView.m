//
//  EDPageViewContainerGraphCacheView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPageViewContainerGraphCacheView.h"

@implementation EDPageViewContainerGraphCacheView

- (id)initWithFrame:(NSRect)frame graphImage:(NSImage *)graphImage
{
    self = [super initWithFrame:frame];
    if (self) {
        _graphImage = graphImage;
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_graphImage){
        NSRect imageRect = NSMakeRect(0, 0, [_graphImage size].width, [_graphImage size].height);
        [_graphImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0 respectFlipped:FALSE hints:nil];
    }
}
@end
