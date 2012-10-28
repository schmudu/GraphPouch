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
#import "NSManagedObject+EasyFetching.h"

@interface EDPagesView()
- (int)getHighlightedDragSection:(int)totalPages pageDragged:(int)pageDragged mousePosition:(float)yPos;
@end

@implementation EDPagesView

- (BOOL)isFlipped{
    return TRUE;
}

- (BOOL)acceptsFirstResponder{
    return TRUE;
}

- (void)postInitialize{
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
- (void)keyDown:(NSEvent *)theEvent{
        //NSLog(@"going to delete something.");
    if ([theEvent keyCode] == EDKeycodeDelete) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesDeletePressed object:self];
    }
}

#pragma mark mouse
- (void)mouseDown:(NSEvent *)theEvent{
    NSLog(@"user clicked");
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
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    int pageCount = [[coreData getAllPages] count];
 
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
    
    //NSLog(@"highlighted:%d highlighted section:%d", _highlighted, _highlightedDragSection);
    //NSLog(@"highlight: page count:%d page dragged:%d current y:%f", pageCount, [[_startDragPageData pageNumber] intValue], pagesPoint.y);
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
    NSArray *pages = [EDPage findAllObjects];
    NSLog(@"===before: reading from pasteboard: page count:%ld", [pages count]);
    NSArray *objects = [_pb readObjectsForClasses:classes options:nil];
    NSLog(@"===after: reading from pasteboard: page count:%ld", [pages count]);
    if ([objects count] > 0) {
        /*
        for (EDPageView *pageView in objects){
            NSLog(@"sending dragged page views: data %@", [pageView dataObj]);
        }*/
        
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        [userDict setObject:objects forKey:EDKeyPagesViewDraggedViews];
        [userDict setValue:[[NSNumber alloc] initWithInt:_highlightedDragSection] forKey:EDKeyPagesViewHighlightedDragSection];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageViewsFinishedDrag object:self userInfo:userDict];
 
        // read data from the pasteboard
        //EDPageView *pageView = [objects objectAtIndex:0];
        
        /*
        if (pageView) {
            NSLog(@"reading from pasteboard: page view:%@", [pageView dataObj]);
            return YES;
        }
        */
        return YES;
    }
    return NO;
}

@end
