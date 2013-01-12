//
//  EDContentView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/8/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDContentView.h"
#import "EDConstants.h"

@implementation EDContentView

/*
- (BOOL)isFlipped{
    return TRUE;
}*/

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

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{
    if ([theEvent keyCode] == EDKeycodeSave) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutSave object:self];
    }
    return [super performKeyEquivalent:theEvent];
}
@end
