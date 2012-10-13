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
    // Drawing code here.
}

#pragma mark keyboard
- (void)keyDown:(NSEvent *)theEvent{
    if ([theEvent keyCode] == EDKeycodeDelete) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesDeletePressed object:self];
    }
}

#pragma mark mouse
- (void)mouseDown:(NSEvent *)theEvent{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesViewClicked object:self];
}

#pragma mark events
- (void)setPageViewStartDragInfo:(EDPage *)pageData{
    NSLog(@"setting data:%@", pageData);
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
       
   _highlighted = TRUE;
   [self setNeedsDisplay:TRUE];
   return NSDragOperationCopy; 
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender{
    NSPoint pagesPoint = [[[self window] contentView] convertPoint:[sender draggingLocation] toView:self];
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    int pageCount = [[coreData getAllPages] count];
    
    NSLog(@"highlight: page count:%d page dragged:%d current y:%f", pageCount, [[_startDragPageData pageNumber] intValue], pagesPoint.y);
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

#pragma mark pasteboard 
/*
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    // encode object
    return NSPasteboardReadingAsKeyedArchive;
}*/

- (BOOL)readFromPasteboard:(NSPasteboard *)pb{
    NSArray *classes = [NSArray arrayWithObject:[EDPageView class]];
    NSArray *objects = [_pb readObjectsForClasses:classes options:nil];
    if ([objects count] > 0) {
        // read data from the pasteboard
        EDPageView *pageView = [objects objectAtIndex:0];
        
        if (pageView) {
            NSLog(@"reading from pasteboard: page view:%@", [pageView dataObj]);
            return YES;
        }
    }
    return NO;
}

@end
