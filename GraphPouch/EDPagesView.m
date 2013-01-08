//
//  EDPagesView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/3/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPagesView.h"
#import "EDPageView.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"
#import "EDCoreDataUtility+Pages.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSColor+Utilities.h"

@interface EDPagesView()
- (int)getHighlightedDragSection:(int)totalPages pageDragged:(int)pageDragged mousePosition:(float)yPos;
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

/*
- (BOOL)acceptsFirstResponder{
    NSLog(@"pages: accept responder:%@", [[self window] firstResponder]);
    if ([[self window] firstResponder] == self) {
        return YES;
    }
    return NO;
}*/

- (void)postInitialize:(NSManagedObjectContext *)context{
    _context = context;
    _pb = [NSPasteboard generalPasteboard];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:EDUTIPage,nil]];
}

- (void)dealloc{
    [self unregisterDraggedTypes];
}

- (void)drawRect:(NSRect)dirtyRect
{
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
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{
    NSLog(@"pages view key equivalent.");
    if ([theEvent keyCode] == EDKeycodeCopy) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutCopy object:self];
        return YES;
    }
    else if ([theEvent keyCode] == EDKeycodeCut) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutCut object:self];
        return YES;
    }
    else if ([theEvent keyCode] == EDKeycodePaste) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutPaste object:self];
        return YES;
    }
    return NO;
}
- (void)keyDown:(NSEvent *)theEvent{
    if ([theEvent keyCode] == EDKeycodeDelete) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesDeletePressed object:self];
    }
}

#pragma mark mouse
- (void)mouseDown:(NSEvent *)theEvent{
    [[self window] makeFirstResponder:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesViewClicked object:self];
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
    int pageCount = [[EDCoreDataUtility getAllPages:_context] count];
 
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
    NSArray *classes = [NSArray arrayWithObject:[EDPageView class]];
    
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

@end
