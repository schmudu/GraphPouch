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
- (void)writeToPasteboard:(NSPasteboard *)pb;
@end

@implementation EDPageView

- (BOOL)isFlipped{
    return TRUE;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pb = [NSPasteboard generalPasteboard];
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        
        // re-implement this when we can start dragging graphs
        //[self registerForDraggedTypes:[NSArray arrayWithObjects:EDUTIGraph,nil]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:[_coreData context]];
    }
    return self;
}

- (void)dealloc{
    [self unregisterDraggedTypes];
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
    
    if (_highlighted){
        //NSLog(@"page view needs to be highlighted.");
    }
    else {
        //NSLog(@"page view will not be highlighted.");
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
- (void)mouseDragged:(NSEvent *)theEvent{
    // Notify listeners
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageViewStartDrag object:self];
    
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
    
    // write to pasteboard
    [self writeToPasteboard:_pb];
    
    // Start the drag
    [self dragImage:anImage at:p offset:NSZeroSize event:_mouseDownEvent pasteboard:_pb source:self slideBack:YES];
    
}

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
}

- (void)drawStringCenteredIn:(NSRect)rect{
    [[NSColor purpleColor] setFill];
    [NSBezierPath fillRect:NSMakeRect(0, 0, EDPageImageViewWidth, EDPageImageViewHeight)];
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

#pragma mark dragging source
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag{
    NSLog(@"dragged image.");
    return NSDragOperationCopy | NSDragOperationDelete;
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation{
    if (operation == NSDragOperationDelete){
        NSLog(@"should delete something.");
    }
    
    // notify listners
    /*
    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] init];
    [eventDict setObject:theEvent forKey:EDKeyPageViewDragPoint];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageViewDragged object:self userInfo:eventDict];
     */
}

#pragma mark dragging destination
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSLog(@"1");
    if([sender draggingSource] == self){
        return NSDragOperationNone;
    }
       
   _highlighted = TRUE;
   [self setNeedsDisplay:TRUE];
   return NSDragOperationCopy; 
}

- (void)draggingExited:(id<NSDraggingInfo>)sender{
    NSLog(@"2");
    _highlighted = FALSE;
    [self setNeedsDisplay:TRUE];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    NSLog(@"3");
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    NSLog(@"4");
    //NSPasteboard *pb = [sender draggingPasteboard];
    if(![self readFromPasteboard:_pb]){
        return NO;
    }
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender{
    NSLog(@"conclude drag operation.");
    _highlighted = FALSE;
    [self setNeedsDisplay:TRUE];
}

#pragma mark pastboard
- (BOOL)readFromPasteboard:(NSPasteboard *)pb{
    NSArray *classes = [NSArray arrayWithObject:[EDPageView class]];
    NSArray *objects = [_pb readObjectsForClasses:classes options:nil];
    if ([objects count] > 0) {
        // read data from the pasteboard
        EDPageView *pageView = [objects objectAtIndex:0];
        
        if (pageView) {
            NSLog(@"reading from pasteboard.");
            return YES;
        }
    }
    return NO;
}

- (void)writeToPasteboard:(NSPasteboard *)pb{
    [_pb clearContents];
    [_pb writeObjects:[NSArray arrayWithObject:self]];
}

#pragma mark pasteboard writing protocol
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    NSArray *writableTypes = nil;
    if (!writableTypes){
        writableTypes = [[NSArray alloc] initWithObjects:EDUTIPage, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type{
    //return self;
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    return 0;
}

#pragma mark pasteboard reading protocol
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    // encode object
    return NSPasteboardReadingAsKeyedArchive;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard{
    return [NSArray arrayWithObject:EDUTIPage];
}

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    if((self=[super init])){
        _highlighted = [aDecoder decodeBoolForKey:EDPageViewAttributeHighlighted];
        _dataObj = [aDecoder decodeObjectForKey:EDPageViewAttributeDataObject];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:_highlighted forKey:EDPageViewAttributeHighlighted];
    [aCoder encodeObject:_dataObj forKey:EDPageViewAttributeDataObject];
}
@end
