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
            float newOriginX = ([view frame].size.width - EDWorksheetViewWidth)/2;
            float newOriginY = ([view frame].size.height - EDWorksheetViewHeight)/2;
            
            [view setFrameOrigin:NSMakePoint(newOriginX, newOriginY)];
            NSLog(@"x:%f y%f scroll width:%f self width:%f", [view frame].origin.x, [self frame].origin.y, [view frame].size.width, [self frame].size.width);
        }
    }
}
@end
