//
//  EDPageView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/3/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPageView.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"

@interface EDPageView()
- (void)onContextChanged:(NSNotification *)note;
@end

@implementation EDPageView

- (BOOL)isFlipped{
    return TRUE;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:[_coreData context]];
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[_coreData context]];
}

- (void)drawRect:(NSRect)dirtyRect
{
    //NSRect bounds = NSMakeRect(([self superview].frame.size.width - EDPageImageViewWidth)/2, 0, EDPageImageViewWidth, EDPageImageViewHeight);
    NSRect bounds = NSMakeRect(40, 0, EDPageImageViewWidth, EDPageImageViewHeight);
    
    if ([[_dataObj selected] boolValue]) {
        [[NSColor blueColor] setFill];
    }
    else {
        [[NSColor redColor] setFill];
    }
    
    //[NSBezierPath fillRect:bounds];
    //NSLog(@"bounds size: frame: x:%f y:%f width%f height:%f", [self frame].origin.x, [self frame].origin.y, [self bounds].size.width, [self bounds].size.height);
    [NSBezierPath fillRect:bounds];
    //NSLog(@"drawing frame x:%f width%f", [self frame].origin.x, [self frame].size.width);
}

#pragma mark data
- (EDPage *)dataObj{
    return _dataObj;
}

- (void)setDataObj:(EDPage *)pageObj{
    _dataObj = pageObj;
}

#pragma mark mouse
- (void)mouseDown:(NSEvent *)theEvent{
    // store for drag operation
    _mouseDownEvent = theEvent;
    
    // listen for modifier keys
    NSUInteger flags = [theEvent modifierFlags];
    
    if ([[_dataObj selected] boolValue]){
        // page is already selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [_dataObj setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDPageAttributeSelected];
        }
        /*
        else{
            [self notifyMouseDownListeners:theEvent];
        }*/
    }
    else {
        // page is not selected
        if(!(flags & NSCommandKeyMask) && !(flags & NSShiftKeyMask)){
            // dispatch event that a new page has been selected
            [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageClickedWithoutModifier object:self];
        }
        
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

- (void)deselectPage{
    // deselect 
    [_dataObj setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDPageAttributeSelected];
    
    // redisplay
    [self setNeedsDisplay:TRUE];
}

- (void)onContextChanged:(NSNotification *)note{
    // code of context changed
}

#pragma mark dragging
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag{
    return NSDragOperationCopy | NSDragOperationDelete;
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation{
    if (operation == NSDragOperationDelete){
        NSLog(@"should delete something.");
    }
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint down = [_mouseDownEvent locationInWindow];
    NSPoint drag = [theEvent locationInWindow];
    float distance = hypotf(down.x - drag.x, down.y - drag.y);
    
    if (distance < 3){
        return;
    }
    
    // validation
    
    // more validations
    NSSize s = NSMakeSize(200, 100);
    
    // create the image
    NSImage *anImage = [[NSImage alloc] initWithSize:s];
    
    // create a rect in which you will draw the letter in the image
    NSRect imageBounds;
    imageBounds.origin = NSZeroPoint;
    imageBounds.size = s;
    
    // draw the letter on the image
    [anImage lockFocus];
    [self drawStringCenteredIn:imageBounds];
    [anImage unlockFocus];
    
    // Get the location of the mouseDown event
    NSPoint p = [[[self window] contentView] convertPoint:down toView:self];
    
    // Drag from the center of the image
    p.x = p.x - EDPageImageViewWidth/2;
    p.y = p.y + EDPageImageViewHeight/2;
    
    // Get the pasteboard
    NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
    
    // Start the drag
    [self dragImage:anImage at:p offset:NSZeroSize event:_mouseDownEvent pasteboard:pb source:self slideBack:YES];
}

- (void)drawStringCenteredIn:(NSRect)rect{
    [[NSColor purpleColor] setFill];
    [NSBezierPath fillRect:NSMakeRect(0, 0, EDPageImageViewWidth, EDPageImageViewHeight)];
}
@end
