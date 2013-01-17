//
//  EDWorksheetClipView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDWorksheetClipView.h"

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
    // Drawing code here.
        [[NSColor grayColor] setFill];
        [NSBezierPath fillRect:[self bounds]];
    /*
    if ([[self window] firstResponder] == [self documentView]) {
        [[NSColor redColor] setFill];
        [NSBezierPath fillRect:[self bounds]];
        NSLog(@"draw rect clip view");
        NSRect frame = NSMakeRect(10, 10, 50, 50);
        //[[NSColor colorWithHexColorString:EDSelectedViewColor] setStroke];
        //[NSBezierPath setDefaultLineWidth:EDSelectedViewStrokeWidth];
        //[NSBezierPath strokeRect:[self frame]];
        [[NSColor redColor] setFill];
        [NSBezierPath fillRect:frame];
    }
    else{
        [[NSColor blueColor] setFill];
        [NSBezierPath fillRect:[self bounds]];
    }*/
}

@end
