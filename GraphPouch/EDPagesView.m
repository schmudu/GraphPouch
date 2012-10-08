//
//  EDPagesView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/3/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPagesView.h"
#import "EDConstants.h"

@implementation EDPagesView

- (BOOL)isFlipped{
    return TRUE;
}

- (BOOL)acceptsFirstResponder{
    return TRUE;
}

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
    // Drawing code here.
}

#pragma mark keyboard
- (void)keyDown:(NSEvent *)theEvent{
    if ([theEvent keyCode] == EDKeycodeDelete) {
        NSLog(@"delete key pressed.");
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesDeletePressed object:self];
    }
}

#pragma mark mouse
- (void)mouseDown:(NSEvent *)theEvent{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesViewClicked object:self];
}

@end
