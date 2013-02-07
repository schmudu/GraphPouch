//
//  EDTextboxViewMask.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/2/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDTextbox.h"
#import "EDTextboxViewMask.h"
#import "EDConstants.h"
#import "EDTextboxView.h"
#import "NSColor+Utilities.h"

@interface EDTextboxViewMask()
- (void)onViewFrameSizeDidChange:(NSNotification *)note;
@end

@implementation EDTextboxViewMask

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // listen
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

- (void)drawRect:(NSRect)dirtyRect
{
    // draw selection is selected
    if ([(EDTextbox *)[(EDTextboxView *)[self superview] dataObj] selected]){
        [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:EDGraphSelectedBackgroundAlpha] set];
        [NSBezierPath fillRect:[self bounds]];
    }
    
    // if enabled then draw dashed border
    if ([(EDTextboxView *)[self superview] enabled]){
        NSBezierPath *aPath;
        aPath = [NSBezierPath bezierPath];
        [aPath setLineWidth:EDTextboxBorderWidth];
        CGFloat dashedLined[] = {10.0, 10.0};
        [aPath setLineDash:dashedLined count:2 phase:0];
        [[NSColor blueColor] setStroke];
        [aPath moveToPoint:NSMakePoint(0, 0)];
        [aPath lineToPoint:NSMakePoint([self frame].size.width, 0)];
        [aPath lineToPoint:NSMakePoint([self frame].size.width, [self frame].size.height)];
        [aPath lineToPoint:NSMakePoint(0, [self frame].size.height)];
        [aPath lineToPoint:NSMakePoint(0, 0)];
        [aPath stroke];
    }
}

- (void)mouseDown:(NSEvent *)theEvent{
    if ([theEvent clickCount] == 2){
        // double click
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDoubleClick object:self];
    }
    else if([theEvent clickCount] == 1){
        NSMutableDictionary *eventInfo = [[NSMutableDictionary alloc] init];
        [eventInfo setObject:theEvent forKey:EDKeyEvent];
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDown object:self userInfo:eventInfo];
    }
}

- (void)onViewFrameSizeDidChange:(NSNotification *)note{
    // match size of superview
    if ([self superview] != nil){
        [self setFrameSize:NSMakeSize([[self superview] frame].size.width, [[self superview] frame].size.height)];
    }
}
@end
