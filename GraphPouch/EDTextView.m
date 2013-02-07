//
//  EDTextView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/5/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDTextView.h"
#import "EDTextboxView.h"

@implementation EDTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //_enabled = TRUE;
    }
    
    return self;
}

- (void)resetCursorRects{
    if ([(EDTextboxView *)[self superview] enabled]){
        [super resetCursorRects];
    }
}

/*
- (BOOL)enabled{
    return _enabled;
}

- (void)setEnabled:(BOOL)newState{
    _enabled = newState;
    
    if (_enabled){
        [self setEditable:TRUE];
        [self setSelectable:TRUE];
    }
    else{
        [self setEditable:FALSE];
        [self setSelectable:FALSE];
    }
}

- (void)toggleEnabled{
    // toggle enable
    if (_enabled){
        _enabled = FALSE;
        [self setEditable:FALSE];
        [self setSelectable:FALSE];
    }
    else{
        _enabled = TRUE;
        [self setEditable:TRUE];
        [self setSelectable:TRUE];
    }
    NSLog(@"just toggle enabled to value:%d", _enabled);
}
 */
@end
