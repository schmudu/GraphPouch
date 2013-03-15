//
//  EDPageViewContainerTextView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/14/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPageViewContainerTextView.h"

@implementation EDPageViewContainerTextView

- (BOOL)isFlipped{
    return TRUE;
}

- (id)initWithFrame:(NSRect)frame textImage:(NSImage *)textImage xRatio:(float)xRatio yRatio:(float)yRatio
{
    self = [super initWithFrame:frame];
    if (self) {
        _textImage = textImage;
        _xRatio = xRatio;
        _yRatio = yRatio;
        
        // set transformation
        [self setFrame:NSMakeRect(0, 0, [_textImage size].width * xRatio, [_textImage size].height * yRatio)];
        [self setBounds:NSMakeRect(0, 0, [_textImage size].width, [_textImage size].height)];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_textImage){
        NSRect imageRect = NSMakeRect(0, 0, [_textImage size].width, [_textImage size].height);
        [_textImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:TRUE hints:nil];
    }
}

@end
