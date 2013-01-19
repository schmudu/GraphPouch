//
//  EDMainContentView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDMainContentView.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"
#import "EDWorksheetView.h"

@interface EDMainContentView()
- (void)onWorksheetSelected:(NSNotification *)note;
- (void)onWorksheetResignedFirstResponder:(NSNotification *)note;
- (void)onWorksheetBecameFirstResponder:(NSNotification *)note;
@end

@implementation EDMainContentView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWorksheetClicked object:_worksheetView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWorksheetViewResignFirstResponder object:_worksheetView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventBecomeFirstResponder object:_worksheetView];
}

- (void)awakeFromNib{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorksheetSelected:) name:EDEventWorksheetClicked object:_worksheetView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorksheetResignedFirstResponder:) name:EDEventWorksheetViewResignFirstResponder object:_worksheetView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorksheetBecameFirstResponder:) name:EDEventBecomeFirstResponder object:_worksheetView];
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithHexColorString:@"cccccc"] setFill];
    [NSBezierPath fillRect:[self bounds]];
    
    // draw drop shadow of document
    //[[NSColor colorWithHexColorString:@"666666"] setFill];
    //NSBezierPath *documentOutline = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat w#>, <#CGFloat h#>) xRadius:5 yRadius:5];
    
    //[NSBezierPath round:NSMakeRect(0, 0, 50, 50)];
    
    
    if ([[self window] firstResponder] == _worksheetView) {
        [[NSColor colorWithHexColorString:EDSelectedViewColor] setStroke];
        [NSBezierPath setDefaultLineWidth:EDSelectedViewStrokeWidth];
        [NSBezierPath strokeRect:[self bounds]];
    }
}

- (void)mouseDown:(NSEvent *)theEvent{
    // mouse click on content view is synonymous with click on worksheet
    [_worksheetView mouseDown:theEvent];
}

-(void)windowDidResize{
    // set new position based on constant width of document and new width
    float worksheetWidth = [_worksheetView frame].size.width;
    float worksheetHeight = [_worksheetView frame].size.height;
    
    float newOriginX = ([self frame].size.width - worksheetWidth)/2;
    float newOriginY = ([self frame].size.height - worksheetHeight)/2;
    
    [_worksheetView setFrameOrigin:NSMakePoint(newOriginX, newOriginY)];
}

#pragma mark events
- (void)onWorksheetSelected:(NSNotification *)note{
    [self setNeedsDisplay:TRUE];
}

- (void)onWorksheetResignedFirstResponder:(NSNotification *)note{
    [self setNeedsDisplay:TRUE];
}

- (void)onWorksheetBecameFirstResponder:(NSNotification *)note{
    [self setNeedsDisplay:TRUE];
}

@end
