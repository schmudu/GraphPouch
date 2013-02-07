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
- (void)onMaskClicked:(NSNotification *)note;
- (void)onMaskDoubleClicked:(NSNotification *)note;
- (void)onWorksheetClicked:(NSNotification *)note;
- (void)disable;
- (void)disableTrackingAreas;
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
        _enabled = FALSE;
        
        // add text field to view
        [_textView insertText:[[NSMutableAttributedString alloc] initWithString:@"Does this work?"]];
        [_textView setDrawsBackground:FALSE];
        [self addSubview:_textView];
        [_textView postInit];
        
        [self addSubview:_mask];
        [_mask postInit];
        
        //[_contentTextfield setStringValue:[NSString stringWithFormat:@"Does this work?"]];
        //[_contentTextfield setAttributedStringValue:[NSMutableAttributedString alloc] initWithString:@"first"];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMaskClicked:) name:EDEventMouseDown object:_mask];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMaskDoubleClicked:) name:EDEventMouseDoubleClick object:_mask];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorksheetClicked:) name:EDEventWorksheetClicked object:[self superview]];
        
    }
    return self;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventMouseDown object:_mask];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWorksheetClicked object:[self superview]];
}

- (void)postInit{
    /*
    // automatically disable tracking areas
    [_textView updateTrackingAreas];
    [self disableTrackingAreas];
    
    [[self window] invalidateCursorRectsForView:self];
     */
    [self disable];
    NSLog(@"tracking areas:%@", [_textView trackingAreas]);
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)onContextChanged:(NSNotification *)note{
    [super onContextChanged:note];
}
#pragma mark disable/enable textbox
- (BOOL)enabled{
    return _enabled;
}

- (void)enable{
    _enabled = TRUE;
 
    // switch order to that mask is in front of text
    [_textView removeFromSuperview];
    [self addSubview:_textView];
    
    // disable text box
    [_textView setEditable:TRUE];
    [_textView setSelectable:TRUE];
    
    // enable all tracking areas
    [_textView addTrackingRect:[_textView frame] owner:self userData:nil assumeInside:NO];
    //[_mask removeFromSuperview];
    
    // need to change cursor rects
    [[self window] invalidateCursorRectsForView:self];
}

- (void)disableTrackingAreas{
    // remove all tracking areas
    NSArray *trackingAreas = [_textView trackingAreas];
    for (NSTrackingArea *area in trackingAreas){
        [_textView removeTrackingArea:area];
    }
}

- (void)disable{
    _enabled = FALSE;
    
    // disable text box
    [_textView setEditable:FALSE];
    [_textView setSelectable:FALSE];
    
    // add the mask
    //[self addSubview:_mask];
 
    // switch order to that mask is in front of text
    [_mask removeFromSuperview];
    [self addSubview:_mask];
    
    // disable tracking areas
    [self disableTrackingAreas];
    
    // need to change cursor rects
    [[self window] invalidateCursorRectsForView:self];
}

- (void)onMaskClicked:(NSNotification *)note{
    [super mouseDown:[[note userInfo] objectForKey:EDKeyEvent]];
}

- (void)onMaskDoubleClicked:(NSNotification *)note{
    // enable text box
    [self enable];
    
    // deselect this element
    [(EDTextbox *)[self dataObj] setSelected:FALSE];
}

- (void)onWorksheetClicked:(NSNotification *)note{
    // worksheet was clicked
    // disable text view
    [self disable];
}
@end