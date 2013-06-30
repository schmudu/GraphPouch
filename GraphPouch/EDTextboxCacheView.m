//
//  EDTextboxCacheView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 6/30/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDTextboxCacheView.h"

@implementation EDTextboxCacheView

- (id)initWithFrame:(NSRect)frame textboxModel:(EDTextbox *)myTextbox drawSelection:(BOOL)drawSelection image:(NSImage *)image{
    self = [super initWithFrame:frame textboxModel:myTextbox drawSelection:drawSelection];
    if (self) {
        _image = image;
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    /*
    if (_image){
        NSRect imageRect = NSMakeRect(0, 0, [_image size].width, [_image size].height);
        [_image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0 respectFlipped:TRUE hints:nil];
    }*/
}

@end
