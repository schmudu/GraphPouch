//
//  EDWorksheetScrollView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDWorksheetScrollView.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"
#import "EDWorksheetClipView.h"

@interface EDWorksheetScrollView()
- (void)onWorksheetViewClicked:(NSNotification *)note;
@end

@implementation EDWorksheetScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWorksheetClicked object:[self documentView]];
}

- (void)postInitialize{
    _clipView = [[EDWorksheetClipView alloc] initWithFrame:[[self contentView] frame]];
    [_clipView setDocumentView:[self documentView]];
    [_clipView setCopiesOnScroll:[[self contentView] copiesOnScroll]];
    
    [self setBackgroundColor:[NSColor purpleColor]];
    // reset clip view
    [self setContentView:_clipView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorksheetViewClicked:) name:EDEventWorksheetClicked object:[self documentView]];
}

- (void)onWorksheetViewClicked:(NSNotification *)note{
    [self setNeedsDisplay:TRUE];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // drawing code
}

- (void)windowDidResize{
    //NSLog(@"window did resize: doc width:%f scroll frame width:%f origin x:%f self origin x:%f", [[self documentView] frame].size.width, [self frame].size.width, [[self contentView] frame].origin.x, [self frame].origin.x);
    NSLog(@"window did resize: doc width:%f doc x:%f", [[self documentView] frame].size.width, [[self documentView] frame].origin.x);
    // center the content view
    [[self documentView] setFrameOrigin:NSMakePoint(([[self documentView] frame].size.width - [[self contentView] frame].size.width)/2, ([[self documentView] frame].size.height - [[self contentView] frame].size.height)/2)];
}
@end
