//
//  EDTextboxView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//
#import "EDTextboxView.h"
#import "EDConstants.h"
#import "EDTextbox.h"
#import "EDTextboxViewMask.h"
#import "NSColor+Utilities.h"
#import "NSManagedObject+Attributes.h"

@interface EDTextboxView()
- (void)onContextChanged:(NSNotification *)note;
- (void)onMaskClicked:(NSNotification *)note;
- (void)onWorksheetClicked:(NSNotification *)note;
- (void)disable;
- (void)enable;
@end

@implementation EDTextboxView
- (id)initWithFrame:(NSRect)frame textboxModel:(EDTextbox *)myTextbox{
    self = [super initWithFrame:frame];
    if (self){
        _context = [myTextbox managedObjectContext];
        _textView = [[EDTextView alloc] initWithFrame:[self bounds]];
        _mask = [[EDTextboxViewMask alloc] initWithFrame:[self bounds]];
        
        // set model info
        [self setDataObj:myTextbox];
        
        [_textView insertText:[[NSMutableAttributedString alloc] initWithString:@"Does this work?"]];
        // add text field to view
        [self addSubview:_textView];
        //[self addSubview:_mask];
        //[_contentTextfield setStringValue:[NSString stringWithFormat:@"Does this work?"]];
        //[_contentTextfield setAttributedStringValue:[NSMutableAttributedString alloc] initWithString:@"first"];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMaskClicked:) name:EDEventMouseDown object:_mask];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorksheetClicked:) name:EDEventWorksheetClicked object:[self superview]];
    }
    return self;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventMouseDown object:_mask];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWorksheetClicked object:[self superview]];
}

- (BOOL)isFlipped{
    return TRUE;
}

#pragma mark disable/enable textbox
- (void)toggle{
    [_textView toggleEnabled];
    
    // toggle enable
    if ([_textView enabled])
        [self enable];
    else
        [self disable];
    
    // reset cursor rects
    [[self window] invalidateCursorRectsForView:self];
}

- (void)enable{
    // enable all tracking areas
    [_textView addTrackingRect:[_textView frame] owner:self userData:nil assumeInside:NO];
    [_mask removeFromSuperview];
}

- (void)disable{
    // remove all tracking areas
    NSArray *trackingAreas = [_textView trackingAreas];
    for (NSTrackingArea *area in trackingAreas){
        [_textView removeTrackingArea:area];
    }
    [self addSubview:_mask];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if ([[self dataObj] isSelectedElement]){
        [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:EDGraphSelectedBackgroundAlpha] set];
        [NSBezierPath fillRect:[self bounds]];
    }
}

- (void)onMaskClicked:(NSNotification *)note{
    //NSLog(@"enabled state%d", [_textView enabled]);
    //[self toggle];
    [super mouseDown:[[note userInfo] objectForKey:EDKeyEvent]];
}

- (void)onWorksheetClicked:(NSNotification *)note{
    // worksheet was clicked
    // disable text view
    [_textView setEnabled:FALSE];
    [self disable];
}
@end