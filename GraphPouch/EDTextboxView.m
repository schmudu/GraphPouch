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
- (void)onWindowDidResignKey:(NSNotification *)note;
- (void)onWorksheetClicked:(NSNotification *)note;
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
        if ([myTextbox textValue]){
            // insert saved data
            [_textView insertText:[myTextbox textValue]];
        }
        else {
            // enter default text
            [_textView insertText:[[NSMutableAttributedString alloc] initWithString:@"Enter text here..."]];
        }
        [_textView setDrawsBackground:FALSE];
        
        // set delegates
        [_textView setDelegate:self];
        [[_textView textStorage] setDelegate:self];
        [self addSubview:_textView];
        [_textView postInit];
        
        [self addSubview:_mask];
        [_mask postInit];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMaskClicked:) name:EDEventMouseDown object:_mask];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMaskDoubleClicked:) name:EDEventMouseDoubleClick object:_mask];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorksheetClicked:) name:EDEventWorksheetClicked object:[self superview]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWindowDidResignKey:) name:NSWindowDidResignKeyNotification object:[self window]];
        
    }
    return self;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventMouseDown object:_mask];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventMouseDoubleClick object:_mask];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWorksheetClicked object:[self superview]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
}

- (void)postInit{
    [self disable];
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
    
    // deselect all text
    [_textView setSelectedRange:NSMakeRange(0, 0)];
    
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
    
    // notify listeners of end of editing
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventTextboxEndEditing object:self];
}

#pragma mark mouse
- (void)onMaskClicked:(NSNotification *)note{
    [super mouseDown:[[note userInfo] objectForKey:EDKeyEvent]];
}

- (void)onMaskDoubleClicked:(NSNotification *)note{
    // enable text box
    [self enable];
    
    // deselect this element
    [(EDTextbox *)[self dataObj] setSelected:FALSE];
    
    // notify listeners of begin of editing
    NSMutableDictionary *textInfo = [[NSMutableDictionary alloc] init];
    [textInfo setObject:_textView forKey:EDKeyTextView];
    [textInfo setObject:[self dataObj] forKey:EDKeyTextbox];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventTextboxBeginEditing object:self userInfo:textInfo];
}

- (void)onWorksheetClicked:(NSNotification *)note{
    // worksheet was clicked
    // disable text view
    [self disable];
}

#pragma mark text field delegate
- (void)textDidEndEditing:(NSNotification *)notification{
    // save text
    NSAttributedString *string = [[_textView textStorage] attributedSubstringFromRange:NSMakeRange(0, [[[_textView textStorage] string] length])];
    [[self dataObj] setTextValue:string];
    
    // disable if ended editing
    [self disable];
}

- (void)textDidChange:(NSNotification *)notification{
    // change notification if any editing occurs
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventTextboxDidChange object:self];
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification{
    // change notification if any attributes change in the text storage
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventTextboxDidChange object:self];
}

- (void)textViewDidChangeSelection:(NSNotification *)notification{
    // change notification if selection changes
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventTextboxDidChange object:self];
}

#pragma mark window
- (void)onWindowDidResignKey:(NSNotification *)note{
    // disable on resign key
    //[self disable];
}

#pragma mark decoration
/*
- (void)selectedTextBold{
    NSArray *selectedRanges = [_textView selectedRanges];
    NSMutableAttributedString *string = [_textView textStorage];
    NSRange range;
    
    [string beginEditing];
    for (int rangeIndex=0; rangeIndex<[selectedRanges count]; rangeIndex++){
        [[selectedRanges objectAtIndex:rangeIndex] getValue:&range];
        [string addAttribute:NSSuperscriptAttributeName value:[NSNumber numberWithInt:1] range:range];
    }
    [string endEditing];
}*/
@end