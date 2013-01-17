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

@end
