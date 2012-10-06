//
//  EDPageView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/3/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPageView.h"
#import "EDConstants.h"

@implementation EDPageView

- (BOOL)isFlipped{
    return TRUE;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = NSMakeRect(0, 10, 42.5, 55);
    NSLog(@"drawing rect: bool value:%d", [[_dataObj selected] boolValue]);
    if ([[_dataObj selected] boolValue]) {
        [[NSColor blueColor] setFill];
    }
    else {
        [[NSColor redColor] setFill];
    }
    
    [NSBezierPath fillRect:bounds];
}

#pragma mark data
- (void)setDataObj:(EDPage *)pageObj{
    _dataObj = pageObj;
}

#pragma mark mouse
- (void)mouseDown:(NSEvent *)theEvent{
    NSLog(@"mouse down.");
    
    NSUInteger flags = [theEvent modifierFlags];
    
    if ([[_dataObj selected] boolValue]){
        // page is already selected
    }
    else {
        // page is not selected
        [_dataObj setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDPageAttributeSelected];
    }
    
    //redraw page
    [self setNeedsDisplay:TRUE];
    
    
    
    /*
     
#warning CAREFUL: any code you change here needs to change in the "mouseDownBySelection" method
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    [coreData getAllObjects];
    
    NSUInteger flags = [theEvent modifierFlags];
 
    //save mouse location
    _savedMouseSnapLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
    _didSnap = FALSE;
    
    if ([[self dataObj] isSelectedElement]){
        // graph is already selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDElementAttributeSelected];
        }
        else{
            [self notifyMouseDownListeners:theEvent];
        }
    } else {
        // graph is not selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
        }
        else {
            // post notification
            [_nc postNotificationName:EDEventUnselectedGraphClickedWithoutModifier object:self];
            
            //need to deselect all the other graphs
            [[self dataObj] setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDElementAttributeSelected];
            
            [self notifyMouseDownListeners:theEvent];
        }
    }
    
    // set variable for dragging
    lastCursorLocation = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];
    
    // set variable for draggin
     lastDragLocation = [[[self window] contentView]convertPoint:[theEvent locationInWindow] toView:[self superview]];
     */
}

@end
