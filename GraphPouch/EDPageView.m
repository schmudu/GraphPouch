//
//  EDPageView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/3/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraph.h"
#import "EDGraphView.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDCoreDataUtility+Graphs.h"
#import "EDPage.h"
#import "EDPageView.h"
#import "EDPageViewContainer.h"
#import "NSColor+Utilities.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDPageView()
- (void)onContextChanged:(NSNotification *)note;
- (void)onPageCommandCut:(NSNotification *)note;
- (void)onPageCommandDelete:(NSNotification *)note;
- (void)setPageAsCurrent;
@end

@implementation EDPageView

- (BOOL)acceptsFirstResponder{
    return TRUE;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pb = [NSPasteboard generalPasteboard];
        
    }
    return self;
}

- (void)dealloc{
    [self unregisterDraggedTypes];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventShortcutCut object:_container];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventShortcutDelete object:_container];
    
}

#pragma mark drawing
- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = NSMakeRect(EDPageImageHorizontalBuffer, (EDPageViewSelectionHeight - EDPageImageViewHeight)/2, EDPageImageViewWidth, EDPageImageViewHeight);
    NSRect selectionBounds = NSMakeRect(EDPageImageHorizontalBuffer - (EDPageViewSelectionWidth - EDPageImageViewWidth)/2, 0, EDPageViewSelectionWidth, EDPageViewSelectionHeight);
    
    NSBezierPath *path;
    
    if ([_dataObj selected]) {
        [[NSColor colorWithHexColorString:EDPageViewSelectionColor alpha:EDPageViewSelectionAlpha] setFill];
        path = [NSBezierPath bezierPathWithRoundedRect:selectionBounds xRadius:5 yRadius:5];
        [path fill];
    }
    
    // page drop shadow
    [[NSColor colorWithHexColorString:@"bbbbbb" alpha:0.3] setStroke];
    [NSBezierPath strokeRect:bounds];
}

#pragma mark data
- (EDPage *)dataObj{
    return _dataObj;
}

- (void)setDataObj:(EDPage *)pageObj{
    _context = [pageObj managedObjectContext];
    _dataObj = pageObj;
    
    // draw container subview
    _container = [[EDPageViewContainer alloc] initWithFrame:[EDPageViewContainer containerFrame] page:pageObj];
    [self addSubview:_container];
    
    // do any post init work
    [_container postInit];
    
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageCommandCut:) name:EDEventShortcutCut object:_container];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageCommandDelete:) name:EDEventShortcutDelete object:_container];
}

#pragma mark mouse
- (void)mouseDragged:(NSEvent *)theEvent{
    // Notify listeners
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageViewStartDrag object:self];
    
    NSPoint down = [_mouseDownEvent locationInWindow];
    
    // more validations
    NSSize s = NSMakeSize(200, 100);
    
    // create the image
    NSData *pageImageData = [_container dataWithPDFInsideRect:[_container bounds]];
    NSImage *dragImage, *numberImage, *circleImage;
    dragImage = [[NSImage alloc] initWithSize:[_container bounds].size];
    
    // number of pages that will be dragged
    NSArray *pagesSelected = [EDCoreDataUtility getAllSelectedPages:_context];
    
    // if more than one page then draw number of pages on image
    // create a rect in which you will draw number of pages being dragged in image
    if ([pagesSelected count] > 1){
        NSRect rect;
        float circleDiameter, offsetY;
        // double digits then it needs to be larger
        if ([pagesSelected count]>9){
            circleDiameter = 25;
            offsetY = -1;
            rect = NSMakeRect(35, 50, circleDiameter, circleDiameter);
        }
        else{
            circleDiameter = 20;
            offsetY = 1;
            rect = NSMakeRect(40, 55, circleDiameter, circleDiameter);
        }
        circleImage = [[NSImage alloc] initWithSize:NSMakeSize(circleDiameter, circleDiameter)];
        
        // text field with number of pages
        NSTextField *numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(rect.origin.x+circleDiameter/2, rect.origin.y, rect.size.width, rect.size.height)];
        [numberField setStringValue:[NSString stringWithFormat:@"%ld", [pagesSelected count]]];
        [numberField setSelectable:FALSE];
        [numberField setEditable:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setBordered:FALSE];
        [numberField setAlignment:NSCenterTextAlignment];
        
        // create field image
        numberImage = [[NSImage alloc] initWithData:[numberField dataWithPDFInsideRect:[numberField bounds]]];
        
        // create drag image with page on it
        dragImage = [[NSImage alloc] initWithData:[_container dataWithPDFInsideRect:[_container bounds]]];
        
        // circle image
        [circleImage lockFocus];
        
        // define size
        NSRect ellipseRect = NSMakeRect(0, 0, circleDiameter, circleDiameter);
        
        // shadow
        NSShadow *shadow=[[NSShadow alloc] init];
        [shadow setShadowOffset:NSMakeSize(0, -3)];
        [shadow setShadowBlurRadius:6];
        [shadow setShadowColor:[NSColor colorWithCalibratedWhite:.2 alpha:0.6]];
        [shadow set];
        [[NSColor colorWithCalibratedWhite:0.9 alpha:0.1] set];
        [[NSBezierPath bezierPathWithOvalInRect:ellipseRect] fill];
        
        // ellipse
        NSBezierPath *ellipse = [NSBezierPath bezierPathWithOvalInRect:ellipseRect];
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.196 green:0.486 blue:0.796 alpha:1.0] endingColor:[NSColor colorWithCalibratedRed:0.164 green:0.411 blue:0.674 alpha:1.0]];
        [gradient drawInBezierPath:ellipse angle:-90];
        [circleImage unlockFocus];
        
        // draw circle and number image in drag image
        [dragImage lockFocus];
        [circleImage drawInRect:NSMakeRect(rect.origin.x, rect.origin.y+2, circleDiameter, circleDiameter) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:TRUE hints:nil];
        [numberImage drawInRect:NSMakeRect(rect.origin.x, rect.origin.y+offsetY, circleDiameter, circleDiameter) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:TRUE hints:nil];
        [dragImage unlockFocus];
    }
    else{
        dragImage = [[NSImage alloc] initWithData:pageImageData];
    }
    
    NSRect imageBounds;
    imageBounds.origin = NSZeroPoint;
    imageBounds.size = s;
    
    // Get the location of the mouseDown event
    NSPoint p = [[[self window] contentView] convertPoint:down toView:self];
    
    // Drag from the center of the image
    p.x = p.x - EDPageImageViewWidth/2;
    p.y = p.y + EDPageImageViewHeight/2;
    
    // Start the drag
    //[self dragImage:image at:p offset:NSZeroSize event:_mouseDownEvent pasteboard:_pb source:self slideBack:YES];
    [self dragImage:dragImage at:p offset:NSZeroSize event:_mouseDownEvent pasteboard:_pb source:self slideBack:YES];
}

- (void)mouseDown:(NSEvent *)theEvent{
    // make pages getAllSelectedWorksheetElements
    [[self window] makeFirstResponder:[self superview]];
    
    // store for drag operation
    _mouseDownEvent = theEvent;
    
    // listen for modifier keys
    NSUInteger flags = [theEvent modifierFlags];
    
    if ([_dataObj selected]){
        // page is already selected
        if((flags & NSCommandKeyMask) || (flags & NSShiftKeyMask)){
            [_dataObj setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDPageAttributeSelected];
        }
        else {
            [self setPageAsCurrent];
        }
    }
    else {
        // page is not selected
        if(!(flags & NSCommandKeyMask) && !(flags & NSShiftKeyMask)){
            // dispatch event that a new page has been selected
            [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageClickedWithoutModifier object:self];
            [self setPageAsCurrent];
        }
        
        [_dataObj setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDPageAttributeSelected];
    }
    
    // dispatch
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:self forKey:EDKeyPageViewData];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageViewMouseDown object:self userInfo:userInfo];
    
    //redraw page
    [self setNeedsDisplay:TRUE];
    
    // if mouse dragged already then we need to catch it and call it's behavior
    // play around with the TimeInterval, more means that it can catch dragging, but less responsive
    NSEvent *nextEvent = [[self window] nextEventMatchingMask:NSLeftMouseDraggedMask untilDate:[[NSDate date] dateByAddingTimeInterval:0.35] inMode:NSDefaultRunLoopMode dequeue:NO];
    if ([nextEvent type] == NSLeftMouseDragged){
        [self mouseDragged:nextEvent];
     }
}

- (void)deselectPage{
    // deselect 
    [_dataObj setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDPageAttributeSelected];
    
    // redisplay
    [self setNeedsDisplay:TRUE];
}

#pragma mark keyboard
- (void)keyDown:(NSEvent *)theEvent{
    if ([theEvent keyCode] == EDKeycodeDelete) {
        // only allow this if there are pages selected
        NSArray *selectedPages = [EDCoreDataUtility getAllSelectedPages:_context];
        NSArray *allPages = [EDPage getAllObjects:_context];
        
        // if there are selected pages and it won't wipe out all pages then allow delete to happen
        if (([selectedPages count] > 0) && ([allPages count] - [selectedPages count] > 1))
            [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesDeletePressed object:self];
    }
}

- (void)onContextChanged:(NSNotification *)note{
    // update if needed
    NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    NSArray *insertedArray = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    NSArray *removedArray = [[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects];
    NSMutableArray *allObjects = [NSMutableArray arrayWithArray:updatedArray];
    [allObjects addObjectsFromArray:insertedArray];
    [allObjects addObjectsFromArray:removedArray];
    // if any object was updated, removed or inserted on this page then this page needs to be updated
    for (NSManagedObject *object in allObjects){
        if ((object == [self dataObj]) || ([(EDPage *)[self dataObj] containsObject:object])){
            [self setNeedsDisplay:TRUE];
        }
    }
}

#pragma mark current
- (void)setPageAsCurrent{
    [EDCoreDataUtility setPageAsCurrent:_dataObj context:_context];
}

#pragma mark dragging source
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag{
    return NSDragOperationCopy | NSDragOperationDelete;
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation{
    if (operation == NSDragOperationDelete){
        NSLog(@"should delete something.");
    }
}

#pragma mark dragging destination
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    if([sender draggingSource] == self){
        return NSDragOperationNone;
    }
       
   _highlighted = TRUE;
   [self setNeedsDisplay:TRUE];
   return NSDragOperationCopy; 
}

- (void)draggingExited:(id<NSDraggingInfo>)sender{
    _highlighted = FALSE;
    [self setNeedsDisplay:TRUE];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    //NSPasteboard *pb = [sender draggingPasteboard];
    
    if(![self readFromPasteboard:_pb]){
        return NO;
    }
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender{
    _highlighted = FALSE;
    [self setNeedsDisplay:TRUE];
}

#pragma mark commands
- (void)onPageCommandCut:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutCut object:self userInfo:[note userInfo]];
}

- (void)onPageCommandDelete:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutDelete object:self userInfo:[note userInfo]];
}

#pragma mark pastboard
- (BOOL)readFromPasteboard:(NSPasteboard *)pb{
    NSArray *classes = [NSArray arrayWithObject:[EDPageView class]];
    NSArray *objects = [_pb readObjectsForClasses:classes options:nil];
    if ([objects count] > 0) {
        // read data from the pasteboard
        EDPageView *pageView = [objects objectAtIndex:0];
        
        if (pageView) {
            return YES;
        }
    }
    return NO;
}

/*
- (void)writeToPasteboard:(NSPasteboard *)pb{
    [_pb clearContents];
    [_pb writeObjects:[NSArray arrayWithObject:self]];
}*/

#pragma mark pasteboard writing protocol
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    NSArray *writableTypes = nil;
    if (!writableTypes){
        writableTypes = [[NSArray alloc] initWithObjects:EDUTIPageView, nil];
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
    return [NSArray arrayWithObject:EDUTIPageView];
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
