//
//  EDPageViewContainerLineView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/18/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPageViewContainerLineView.h"
#import "EDConstants.h"
#import "EDLineView.h"

@implementation EDPageViewContainerLineView

- (id)initWithFrame:(NSRect)frame line:(EDLine *)line context:(NSManagedObjectContext *)context
{
    self = [super initWithFrame:frame];
    if (self) {
        _line = line;
        _context = context;
        
        float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
        float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
        
        EDLineView *graphView = [[EDLineView alloc] initWithFrame:NSMakeRect(0, 0, [_line elementWidth], [_line elementHeight]) lineModel:_line drawSelection:TRUE];
        
        // scale image to page view container
        NSRect thumbnailRect = NSMakeRect(0, 0, [_line elementWidth] * xRatio, [_line elementHeight] * yRatio);
        NSImage *lineImage = [[NSImage alloc] initWithData:[graphView dataWithPDFInsideRect:[graphView frame]]];
        NSImageView *imageViewLine = [[NSImageView alloc] initWithFrame:thumbnailRect];
        [imageViewLine setImageScaling:NSScaleProportionally];
        [imageViewLine setImage:lineImage];
        
        // add expression view to stage
        [self addSubview:imageViewLine];
        
        // position it
        [self setFrameOrigin:NSMakePoint([_line locationX] * xRatio, [_line locationY] * yRatio)];
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

/*
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
 */

@end
