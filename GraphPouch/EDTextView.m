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
    }
    
    return self;
}

- (void)postInit{
    // called after class has been added as a view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onViewFrameSizeDidChange:) name:NSViewFrameDidChangeNotification object:[self superview]];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:[self superview]];
}

/*
- (void)resetCursorRects{
    if ([(EDTextboxView *)[self superview] enabled]){
        [super resetCursorRects];
     
        // enabled, by default set cursor at end of textbox
        [self setSelectedRange:NSMakeRange(0, [[self string] length])];
        
        // make this the first responder
        [[self window] makeFirstResponder:self];
    }
}*/

- (void)selectAllText{
    // enabled, by default set cursor at end of textbox
    [self setSelectedRange:NSMakeRange(0, [[self string] length])];
    
    // make this the first responder
    [[self window] makeFirstResponder:self];
}

- (void)onViewFrameSizeDidChange:(NSNotification *)note{
    // match size of superview
    if ([self superview] != nil){
        [self setFrameSize:NSMakeSize([[self superview] frame].size.width, [[self superview] frame].size.height)];
    }
}
@end
