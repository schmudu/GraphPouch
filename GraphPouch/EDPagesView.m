//
//  EDPagesView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/3/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDCoreDataUtility.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDPagesView.h"
#import "EDPageView.h"
#import "EDPageViewContainer.h"
#import "EDPagesViewSelectionView.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSColor+Utilities.h"

@interface EDPagesView()
- (int)getHighlightedDragSection:(int)totalPages pageDragged:(int)pageDragged mousePosition:(float)yPos;
- (void)onMenuPageAdd:(id)sender;
@end

@implementation EDPagesView

- (BOOL)isFlipped{
    return TRUE;
}

#pragma mark first responder
- (BOOL)becomeFirstResponder{
    [self setNeedsDisplay:TRUE];
    return YES;
}

- (BOOL)resignFirstResponder{
    [self setNeedsDisplay:TRUE];
    return YES;
}

- (void)postInitialize:(NSManagedObjectContext *)context{
    _context = context;
    _pb = [NSPasteboard generalPasteboard];
    
    // what types of dragging elements we receive
    [self registerForDraggedTypes:[NSArray arrayWithObjects:EDUTIPage,nil]];
    
    // view that handles dragging selection
    _selectionView = [[EDPagesViewSelectionView alloc] initWithFrame:[self bounds]];
}

- (void)dealloc{
    [self unregisterDraggedTypes];
}

- (void)drawRect:(NSRect)dirtyRect{
    if ((_highlighted) && (_highlightedDragSection > 0)) {
        NSRect highlightRect = NSMakeRect(EDPageViewDragPosX, (_highlightedDragSection - 1) * EDPageViewIncrementPosY - EDPageViewDragOffsetY, EDPageViewDragWidth, EDPageViewDragLength);
        [NSBezierPath fillRect:highlightRect];
    }
    
    if ([[self window] firstResponder] == self) {
        [[NSColor colorWithHexColorString:EDSelectedViewColor] setStroke];
        [NSBezierPath setDefaultLineWidth:EDSelectedViewStrokeWidth];
        [NSBezierPath strokeRect:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height-EDSelectedViewStrokeWidth)];
    }
}

- (int)getHighlightedDragSection:(int)totalPages pageDragged:(int)pageDragged mousePosition:(float)yPos{
    // if number of pages is unacceptable
    if (totalPages <= 1)
        return -1;
    
    // returns which section needs to be highlighted
    if (yPos < EDPageViewOffsetY/2) {
        if (pageDragged == 1) {
            // page already dragged is 1
            // can't drag to same position
            return -1;
        }
        return 1;
    }
    else {
        int pageSection = ((yPos - EDPageViewOffsetY/2) / EDPageViewIncrementPosY) + 1;
        if (pageSection == pageDragged) {
            // can't drag to same position
            return -1;
        }
        else {
            if (pageDragged < pageSection) {
                pageSection++;
            }
        }
        
        // can't drag to section greater than +1 of total pages
        if (pageSection > totalPages) {
            pageSection = totalPages + 1;
        }
        
        return pageSection;
    }
}
#pragma mark keyboard
/*
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{
    // skip these shortcuts if this is not the key window and this is view is not the first responder
    if ((![[self window] isKeyWindow]) || ([[self window] firstResponder] != self)){
        return [super performKeyEquivalent:theEvent];
    }
    
    return NO;
}*/

- (IBAction)cut:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutCut object:self];
}

- (IBAction)copy:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutCopy object:self];
}

- (IBAction)selectAll:(id)sender{
    [EDCoreDataUtility selectAllPages:_context];
}

- (IBAction)deselectAll:(id)sender{
    [EDCoreDataUtility deselectAllPages:_context];
}

- (void)keyDown:(NSEvent *)theEvent{
    NSUInteger flags = [theEvent modifierFlags];
    if(flags == EDKeyModifierNone && [theEvent keyCode] == EDKeycodeTab){
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventTabPressedWithoutModifiers object:self];
    }
    if ([theEvent keyCode] == EDKeycodeDelete) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesDeletePressed object:self];
    }
}

#pragma mark menu
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    // CRUD
    if ([[menuItem title] isEqualToString:@"Copy"]){
        NSArray *items = [EDCoreDataUtility getAllSelectedPages:_context];
        if ([items count] > 0)
            return TRUE;
        else
            return FALSE;
    }
    
    if ([[menuItem title] isEqualToString:@"Cut"]){
        NSArray *items = [EDCoreDataUtility getAllSelectedPages:_context];
        if ([items count] > 0)
            return TRUE;
        else
            return FALSE;
    }
    
    if ([[menuItem title] isEqualToString:@"Select All"]){
        return TRUE;
    }
    
    if ([[menuItem title] isEqualToString:@"Deselect All"]){
        return TRUE;
    }
    
    if ([[menuItem title] isEqualToString:@"Add Page"]){
        return TRUE;
    }
    
    return [super validateMenuItem:menuItem];
}

#pragma mark mouse
- (void)mouseDown:(NSEvent *)theEvent{
    // store mouse down point
    _mousePointDown = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
    
    [[self window] makeFirstResponder:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesViewClicked object:self];
    
    // add selection view
    //_selectionView = [[EDPagesViewSelectionView alloc] initWithFrame:[self bounds]];
    [_selectionView setFrame:[self bounds]];
    [self addSubview:_selectionView];
}

- (void)mouseUp:(NSEvent *)theEvent{
    // remove view
    [_selectionView removeFromSuperview];
    
    // reset mouse points
    //[self setNeedsDisplay:TRUE];
    [_selectionView resetPoints];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    // get mouse point drag
    _mousePointDrag = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:self];
    
    // set the selection view and it will draw
    [_selectionView setMouseDragPoint:_mousePointDrag mouseDownPoint:_mousePointDown];
    
    // if mouse points are set then notify listeners who will actually select the page
    if ((_mousePointDown.x != -1) && (_mousePointDown.y != -1)){
        // notify listeners of drag
        NSMutableDictionary *dragDict = [NSMutableDictionary dictionary];
        [dragDict setValue:[NSValue valueWithPoint:_mousePointDown] forKey:EDKeyPointDown];
        [dragDict setValue:[NSValue valueWithPoint:_mousePointDrag] forKey:EDKeyPointDrag];
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventMouseDragged object:self userInfo:dragDict];
        
        // create selection rectangle
        float xStart, yStart;
        if (_mousePointDown.x < _mousePointDrag.x)
            xStart = _mousePointDown.x;
        else
            xStart = _mousePointDrag.x;
        
        if (_mousePointDown.y < _mousePointDrag.y)
            yStart = _mousePointDown.y;
        else
            yStart = _mousePointDrag.y;
        
        NSRect selectionRect = NSMakeRect(xStart, yStart, fabsf(_mousePointDown.x - _mousePointDrag.x), fabsf(_mousePointDown.y - _mousePointDrag.y));
        
        // select pages that are in the rect
        NSRect pageContainerRect;
        BOOL doesIntersect;
        NSMutableArray *selectedPages = [NSMutableArray array];
        for (id view in [self subviews]){
            if (![view isKindOfClass:[EDPageView class]])
                continue;
            
            // if view is within the selection rectangle then have it selected
            pageContainerRect = NSMakeRect([(EDPageView *)view frame].origin.x + [EDPageViewContainer containerFrame].origin.x, [(EDPageView *)view frame].origin.y + [EDPageViewContainer containerFrame].origin.y, [EDPageViewContainer containerFrame].size.width, [EDPageViewContainer containerFrame].size.height);
            doesIntersect = NSIntersectsRect(selectionRect, pageContainerRect);
            
            // if intersects then add to the array
            if (doesIntersect)
                [selectedPages addObject:[(EDPageView *)view dataObj]];
        }
        
        // tell model to select the pages and deselect the rest
        [EDCoreDataUtility selectOnlyPages:selectedPages context:_context];
    }
}

#pragma mark events
- (void)setPageViewStartDragInfo:(EDPage *)pageData{
    _startDragPageData = pageData;
}

#pragma mark dragging destination
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard{
    return [NSArray arrayWithObject:EDUTIPage];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    if([sender draggingSource] == self){
        return NSDragOperationNone;
    }
       
   [self setNeedsDisplay:TRUE];
   return NSDragOperationCopy; 
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender{
    NSPoint pagesPoint = [[[self window] contentView] convertPoint:[sender draggingLocation] toView:self];
    int pageCount = (int)[[EDCoreDataUtility getAllPages:_context] count];
 
    if (pageCount <= 1) {
        // if there is only one page or less do not highlight
        _highlighted = FALSE;
    }
    else{
        _highlighted = TRUE;
        _highlightedDragSection = [self getHighlightedDragSection:pageCount pageDragged:[[_startDragPageData pageNumber] intValue] mousePosition:pagesPoint.y];
    }
    
    // redraw
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
    // if drag section is -1 then do not allow drag
    if (_highlightedDragSection == -1)
        return NO;
        
    // if there is only one page or less do not allow drag
    if ([[EDCoreDataUtility getAllPages:_context] count] <= 1) 
        return NO;
    
    // going to insert pages from PagesViewController after we have removed pages
    if(![self readFromPasteboard:_pb]){
        return NO;
    }
    
    // finished
    _highlighted = FALSE;
    [self setNeedsDisplay:TRUE];
    
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender{
    [self setNeedsDisplay:TRUE];
}

#pragma mark pasteboard 
/*
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    // encode object
    return NSPasteboardReadingAsKeyedArchive;
}*/

- (BOOL)readFromPasteboard:(NSPasteboard *)pb{
    NSArray *classes = [NSArray arrayWithObject:[EDPage class]];
    
    // get first and last selected objects
    NSArray *selectedPages = [EDPage getAllSelectedObjectsOrderedByPageNumber:_context];
    EDPage *firstSelectedPage = (EDPage *)[selectedPages objectAtIndex:0];
    EDPage *lastSelectedPage = (EDPage *)[selectedPages lastObject];
    
    NSArray *objects = [_pb readObjectsForClasses:classes options:nil];
    
    // add pages that were stored in the pasteboard
    if ([objects count] > 0) {
        
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        [userDict setObject:objects forKey:EDKeyPagesViewDraggedViews];
        [userDict setObject:firstSelectedPage forKey:EDKeySelectedPageFirst];
        [userDict setObject:lastSelectedPage forKey:EDKeySelectedPageLast];
        [userDict setValue:[[NSNumber alloc] initWithInt:_highlightedDragSection] forKey:EDKeyPagesViewHighlightedDragSection];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageViewsFinishedDrag object:self userInfo:userDict];
 
        return YES;
    }
    return NO;
}

#pragma mark menus
- (NSMenu *)menuForEvent:(NSEvent *)event{
    NSMenu *returnMenu = [[NSMenu alloc] init];
    //NSMenuItem *itemPageAdd = [[NSMenuItem alloc] initWithTitle:@"Add Page" action:@selector(onMenuPageAdd:) keyEquivalent:nil];
    [returnMenu addItemWithTitle:@"Add Page" action:@selector(onMenuPageAdd:) keyEquivalent:@""];
    return returnMenu;
}

- (void)onMenuPageAdd:(id)sender{
    NSLog(@"add page:%@", sender);
    [[[self window] firstResponder] doCommandBySelector:@selector(pageAdd:)];
}
@end
