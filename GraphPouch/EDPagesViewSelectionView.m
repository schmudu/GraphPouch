//
//  EDPagesViewSelectionView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/22/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPagesViewSelectionView.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"

@implementation EDPagesViewSelectionView

- (BOOL)isFlipped{
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
    // draw selection rectangle if points are set
    if ((_mousePointDown.x != -1) && (_mousePointDrag.x != -1)){
        [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:EDGraphSelectedBackgroundAlpha] setFill];
        [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:1.0] setStroke];
        
        float xStart, yStart;
        if (_mousePointDown.x < _mousePointDrag.x)
            xStart = _mousePointDown.x;
        else
            xStart = _mousePointDrag.x;
        
        if (_mousePointDown.y < _mousePointDrag.y)
            yStart = _mousePointDown.y;
        else
            yStart = _mousePointDrag.y;
        
        // draw rectangle
        [NSBezierPath fillRect:NSMakeRect(xStart, yStart, fabsf(_mousePointDown.x - _mousePointDrag.x),fabsf(_mousePointDown.y - _mousePointDrag.y))];
        [NSBezierPath strokeRect:NSMakeRect(xStart, yStart, fabsf(_mousePointDown.x - _mousePointDrag.x),fabsf(_mousePointDown.y - _mousePointDrag.y))];
    }
    
}

- (void)resetPoints{
    _mousePointDown = NSMakePoint(-1, -1);
    _mousePointDrag = NSMakePoint(-1, -1);
}

- (void)setMouseDragPoint:(NSPoint)mouseDragPoint mouseDownPoint:(NSPoint)mouseDownPoint{
    _mousePointDown = mouseDownPoint;
    _mousePointDrag = mouseDragPoint;
    if ((_mousePointDown.x != -1) && (_mousePointDown.y != -1)){
        [self setNeedsDisplay:TRUE];
    }
}
@end
