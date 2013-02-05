//
//  EDTextboxView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//
#import "EDTextboxView.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"
#import "EDTextbox.h"
#import "EDTextboxViewMask.h"

@interface EDTextboxView()
- (void)onContextChanged:(NSNotification *)note;
- (void)onMaskClicked:(NSNotification *)note;
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
    }
    return self;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventMouseDown object:_mask];
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)toggle{
    //[_textView toggleEnabled];
    
    // toggle enable
    if ([_textView enabled]){
        // enable all tracking areas
        [_textView addTrackingRect:[_textView frame] owner:self userData:nil assumeInside:NO];
        [_mask removeFromSuperview];
    }
    else{
        // remove all tracking areas
        NSArray *trackingAreas = [_textView trackingAreas];
        for (NSTrackingArea *area in trackingAreas){
            [_textView removeTrackingArea:area];
        }
        [self addSubview:_mask];
        NSLog(@"removed all tracking areas:%@", trackingAreas);
    }
    
    // reset cursor rects
    [[self window] invalidateCursorRectsForView:self];
}


- (void)onContextChanged:(NSNotification *)note{
    // this enables undo method to work
    NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    
    BOOL hasChanged = FALSE;
    int i = 0;
    NSManagedObject *element;
    
    // search through updated array and see if this element has changed
    while ((i<[updatedArray count]) && (!hasChanged)){
        element = [updatedArray objectAtIndex:i];
        // if data object changed or any of the points, update graph
        if (element == [self dataObj]){
            hasChanged = TRUE;
            [self updateDisplayBasedOnContext];
        }
        i++;
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    // drawing code
}

- (void)mouseDown:(NSEvent *)theEvent{
    NSLog(@"mouse down text box view.");
}

- (void)onMaskClicked:(NSNotification *)note{
    //NSLog(@"enabled state%d", [_textView enabled]);
    [self toggle];
}
@end