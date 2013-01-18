//
//  EDMainContentView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDMainContentView.h"
#import "EDWorksheetScrollView.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"

@implementation EDMainContentView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [[NSColor grayColor] setFill];
    [NSBezierPath fillRect:[self bounds]];
    
    /*
     if ([[self window] firstResponder] == [self documentView]) {
        [[NSColor colorWithHexColorString:EDSelectedViewColor] setStroke];
        [NSBezierPath setDefaultLineWidth:EDSelectedViewStrokeWidth];
        [NSBezierPath strokeRect:[self bounds]];
    }*/
}

-(void)windowDidResize{
    for (NSView *view in [self subviews]){
        if ([view isKindOfClass:[EDWorksheetScrollView class]]){
            // set new position based on constant width of document and new width
            float worksheetWidth = [view frame].size.width;
            float worksheetHeight = [view frame].size.height;
            
            /*
            if (EDWorksheetViewHeight > [self frame].size.height)
                worksheetHeight = EDWorksheetViewWidth;
            else
                worksheetHeight = [self frame].size.height;
            
            if (EDWorksheetViewWidth > [self frame].size.width)
                worksheetWidth = EDWorksheetViewWidth;
            else
                worksheetWidth = [self frame].size.width;
            */
            //float newOriginX = ([view frame].size.width - [self frame].size.width)/2;
            //float newOriginY = ([view frame].size.height - [self frame].size.height)/2;
            float newOriginX = ([self frame].size.width - worksheetWidth)/2;
            float newOriginY = ([self frame].size.height - worksheetHeight)/2;
            
            // constraints
            /*
            if (newOriginY < 10){
                newOriginY = 10;
            }*/
            [view setFrameOrigin:NSMakePoint(newOriginX, newOriginY)];
            //NSLog(@"self y:%f x:%f y%f scroll width:%f self width:%f", [self frame].origin.y, [view frame].origin.x, [self frame].origin.y, [view frame].size.width, [self frame].size.width);
            NSLog(@"self y:%f self height:%f scroll y:%f scroll height:%f window height:%f", [self frame].origin.y, [self frame].size.height, [view frame].origin.y, [view frame].size.height, [[self window] frame].size.height);
        }
    }
}
@end
