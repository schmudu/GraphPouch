//
//  EDWorksheetClipView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDWorksheetClipView.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"

@implementation EDWorksheetClipView

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
    [super drawRect:dirtyRect];
    // Drawing code here.
    [[NSColor grayColor] setFill];
    [NSBezierPath fillRect:[self bounds]];
    
    if ([[self window] firstResponder] == [self documentView]) {
        [[NSColor colorWithHexColorString:EDSelectedViewColor] setStroke];
        [NSBezierPath setDefaultLineWidth:EDSelectedViewStrokeWidth];
        [NSBezierPath strokeRect:[self bounds]];
    }
}

@end
