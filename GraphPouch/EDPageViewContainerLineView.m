//
//  EDPageViewContainerLineView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/18/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPageViewContainerLineView.h"
#import "EDConstants.h"

@implementation EDPageViewContainerLineView

- (BOOL)isFlipped{
    return TRUE;
}

- (id)initWithFrame:(NSRect)frame line:(EDLine *)line
{
    self = [super initWithFrame:frame];
    if (self) {
        _line = line;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
    float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
    [[NSColor blackColor] setStroke];
    [path setLineWidth:(yRatio * [_line thickness])];
    [path moveToPoint:NSMakePoint(xRatio * [_line locationX], yRatio *([_line locationY] + EDWorksheetLineSelectionHeight/2))];
    [path lineToPoint:NSMakePoint(xRatio * ([_line locationX] + [_line elementWidth]), yRatio *([_line locationY] + EDWorksheetLineSelectionHeight/2))];
    [path stroke];
}

@end
