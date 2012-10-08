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
    //NSRect bounds = NSMakeRect(0, 10, 42.5, 55);
    
    if ([[_dataObj selected] boolValue]) {
        [[NSColor blueColor] setFill];
    }
    else {
        [[NSColor redColor] setFill];
    }
    
    //[NSBezierPath fillRect:bounds];
    //NSLog(@"bounds size: frame: x:%f y:%f width%f height:%f", [self frame].origin.x, [self frame].origin.y, [self bounds].size.width, [self bounds].size.height);
    [NSBezierPath fillRect:[self bounds]];
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
    return NSDragOperationCopy;
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint down = [_mouseDownEvent locationInWindow];
    NSPoint drag = [theEvent locationInWindow];
    float distance = hypotf(down.x - drag.x, down.y - drag.y);
    NSLog(@"distance:%f", distance);
    if (distance < 3){
        return;
    }
    
    // validation
    /*
    if ([tring length] == 0){
        return;
    }
     */
    // more validations
    //NSSize s = [string sizeWithAttributes:attributes];
    NSSize s = NSMakeSize(100, 100);
    
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
    NSPoint p = [[[self window] contentView] convertPoint:down toView:[self superview]];
    NSLog(@"point for dragging: x:%f y:%f", p.x, p.y);
    // Drag from the center of the image
    p.x = p.x - s.width/2;
    p.y = p.y - s.height/2;
    //p.x = 0;
    //p.y = 0;
    // Get the pasteboard
    NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
    
    // Start the drag
    [self dragImage:anImage at:p offset:NSZeroSize event:_mouseDownEvent pasteboard:pb source:self slideBack:YES];
}

- (void)drawStringCenteredIn:(NSRect)rect{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSFont fontWithName:@"Helvetica" size:75]
                   forKey:NSFontAttributeName];
    [attributes setObject:[NSColor redColor]
                   forKey:NSForegroundColorAttributeName]; 
    
    NSString *string = [[NSString alloc] initWithFormat:@"Patrick"];
    NSSize strSize = NSMakeSize(40, 80);
    NSPoint strOrigin;
    strOrigin.x = rect.origin.x + ((rect.size.width - strSize.width)/2);
    strOrigin.y = rect.origin.y + ((rect.size.height - strSize.height)/2);
    //[string drawAtPoint:strOrigin withAttributes:attributes]; 
    [string drawAtPoint:NSMakePoint(0, 0) withAttributes:attributes]; 
    /*
    [[NSColor purpleColor] setFill];
    [NSBezierPath fillRect:NSMakeRect(0, 0, 40, 40)];
     */
}
@end
