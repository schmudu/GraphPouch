//
//  EDPageViewContainer.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/19/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDCoreDataUtility+Graphs.h"
#import "EDCoreDataUtility+Lines.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDPageViewContainerExpressionView.h"
#import "EDGraphView.h"
#import "EDGraph.h"
#import "EDLine.h"
#import "EDPageViewContainer.h"
#import "EDPageViewContainerGraphView.h"
#import "EDPageViewContainerGraphCacheView.h"
#import "EDPageViewContainerLineView.h"
#import "EDPageViewContainerLineCacheView.h"
#import "EDPageViewContainerTextView.h"
#import "EDPage.h"
#import "EDTextbox.h"
#import "EDTextboxView.h"
#import "NSColor+Utilities.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDPageViewContainer()
- (void)onContextChanged:(NSNotification *)note;

// context menu
- (void)onMenuPageCopy:(id)sender;
- (void)onMenuPageCut:(id)sender;
- (void)onMenuPageDelete:(id)sender;
- (void)onMenuPageDeselect:(id)sender;
- (void)onMenuPageSelect:(id)sender;
- (void)onMenuPageSetCurrent:(id)sender;

// elements
- (void)updateElements;

// expressions
- (void)drawExpressions;
- (void)removeExpressions;

// graphs
- (void)drawGraphs;
- (void)removeGraphs;

// lines
- (void)drawLines;
- (void)removeLines;

// textboxes
- (void)drawTextboxes;
- (void)removeTextboxes;
@end

@implementation EDPageViewContainer

+ (NSRect)containerFrame{
    return NSMakeRect(EDPageImageHorizontalBuffer, (EDPageViewSelectionHeight - EDPageImageViewHeight)/2, EDPageImageViewWidth, EDPageImageViewHeight);
}

- (id)initWithFrame:(NSRect)frame page:(EDPage *)page
{
    self = [super initWithFrame:frame];
    if (self) {
        _page = page;
        _context = [page managedObjectContext];
        _textboxViews = [[NSMutableArray alloc] init];
        _graphCacheViews = [[NSMutableArray alloc] init];
        _lineCacheViews = [[NSMutableArray alloc] init];
        _expressionCacheViews = [[NSMutableArray alloc] init];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    
    return self;
}

- (void)postInit{
    // update textboxes
    [self updateElements];
    
    // draw any elements if necessary
    [self displayRect:[self bounds]];
    [self setNeedsDisplay:TRUE];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

#pragma mark context menu
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    
    if ([[menuItem title] isEqualToString:EDContextMenuPageMakeCurrent]){
        // do not allow if this page is already current
        if ([_page currentPage])
            return FALSE;
        else
            return TRUE;
    }
    
    if ([[menuItem title] isEqualToString:EDContextMenuPageSelect]){
        if ([_page selected])
            return FALSE;
        else
            return TRUE;
    }
    
    if ([[menuItem title] isEqualToString:EDContextMenuPageDeselect]){
        if ([_page selected])
            return TRUE;
        else
            return FALSE;
    }
    
    if ([[menuItem title] isEqualToString:EDContextMenuPagesCopy]){
        return TRUE;
    }
    
    if (([[menuItem title] isEqualToString:EDContextMenuPagesDelete]) ||
        ([[menuItem title] isEqualToString:EDContextMenuPagesCut])){
        // if this is not the only page then return TRUE
        NSArray *pages = [EDPage getAllObjects:_context];
        if ([pages count] > 1)
            return TRUE;
        else
            return FALSE;
    }
    
    return [super validateMenuItem:menuItem];
}

- (NSMenu *)menuForEvent:(NSEvent *)event{
    NSMenu *returnMenu = [[NSMenu alloc] init];
    
    [returnMenu addItemWithTitle:EDContextMenuPagesCopy action:@selector(onMenuPageCopy:) keyEquivalent:@"c"];
    [returnMenu addItemWithTitle:EDContextMenuPagesCut action:@selector(onMenuPageCut:) keyEquivalent:@"x"];
    [returnMenu addItemWithTitle:EDContextMenuPagesDelete action:@selector(onMenuPageDelete:) keyEquivalent:@""];
    [returnMenu addItem:[NSMenuItem separatorItem]];
    [returnMenu addItemWithTitle:EDContextMenuPageMakeCurrent action:@selector(onMenuPageSetCurrent:) keyEquivalent:@""];
    [returnMenu addItem:[NSMenuItem separatorItem]];
    [returnMenu addItemWithTitle:EDContextMenuPageDeselect action:@selector(onMenuPageDeselect:) keyEquivalent:@""];
    [returnMenu addItemWithTitle:EDContextMenuPageSelect action:@selector(onMenuPageSelect:) keyEquivalent:@""];
    return returnMenu;
}

- (void)onMenuPageSelect:(id)sender{
    [EDCoreDataUtility setPageAsSelected:_page context:_context];
}

- (void)onMenuPageDeselect:(id)sender{
    [EDCoreDataUtility setPageAsDeselected:_page context:_context];
}

- (void)onMenuPageCopy:(id)sender{
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:[NSArray arrayWithObject:_page]];
}

- (void)onMenuPageCut:(id)sender{
    NSMutableDictionary *dict = [NSDictionary dictionaryWithObject:_page forKey:EDKeyPagesToRemove];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutCut object:self userInfo:dict];
}

- (void)onMenuPageDelete:(id)sender{
    NSMutableDictionary *dict = [NSDictionary dictionaryWithObject:_page forKey:EDKeyPagesToRemove];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutDelete object:self userInfo:dict];
}

- (void)onMenuPageSetCurrent:(id)sender{
    [EDCoreDataUtility setPageAsCurrent:_page context:_context];
}
#pragma mark drawing
- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

#pragma mark expressions
- (void)drawExpressions{
    NSArray *expressions = [[_page expressions] allObjects];
    EDPageViewContainerExpressionView *expressionView;
    NSImage *expressionImage;
    
    // for each graph create a graph view
    for (EDExpression *expression in expressions){
        expressionView = [[EDPageViewContainerExpressionView alloc] initWithFrame:[self bounds] expression:expression context:_context];
        
        // create image
        /*
        lineImage = [[NSImage alloc] initWithData:[lineView dataWithPDFInsideRect:[lineView bounds]]];
        
        // create cache image that only needs to draw on update
        lineCacheView = [[EDPageViewContainerLineCacheView alloc] initWithFrame:[self bounds] lineImage:lineImage];
        
        //[lineCacheView setFrameOrigin:NSMakePoint(xRatio * [line locationX], yRatio * [line locationY])];
         */
        [self addSubview:expressionView];
        
        // save view so it can be erased later
        [_expressionCacheViews addObject:expressionView];
    }
    
}

- (void)removeExpressions{
    for (NSView *expressionCacheView in _expressionCacheViews){
        [expressionCacheView removeFromSuperview];
    }
    
    // remove all objects
    [_expressionCacheViews removeAllObjects];
}

#pragma mark lines
- (void)drawLines{
    NSArray *lines = [[_page lines] allObjects];
    EDPageViewContainerLineView *lineView;
    EDPageViewContainerLineCacheView *lineCacheView;
    NSImage *lineImage;
    
    // for each graph create a graph view
    for (EDLine *line in lines){
        lineView = [[EDPageViewContainerLineView alloc] initWithFrame:[self bounds] line:line];
        
        // create image
        lineImage = [[NSImage alloc] initWithData:[lineView dataWithPDFInsideRect:[lineView bounds]]];
        
        // create cache image that only needs to draw on update
        lineCacheView = [[EDPageViewContainerLineCacheView alloc] initWithFrame:[self bounds] lineImage:lineImage];
        
        //[lineCacheView setFrameOrigin:NSMakePoint(xRatio * [line locationX], yRatio * [line locationY])];
        [self addSubview:lineCacheView];
        
        // save view so it can be erased later
        [_lineCacheViews addObject:lineCacheView];
    }
}

- (void)removeLines{
    for (NSView *lineCacheView in _lineCacheViews){
        [lineCacheView removeFromSuperview];
    }
    
    // remove all objects
    [_lineCacheViews removeAllObjects];
}

#pragma mark graphs
- (void)drawGraphs{
    NSArray *graphs = [[_page graphs] allObjects];
    EDPageViewContainerGraphView *graphView;
    
    // for each graph create a graph view
    for (EDGraph *graph in graphs){
        graphView = [[EDPageViewContainerGraphView alloc] initWithFrame:[self bounds] graph:graph context:_context];
        
        [self addSubview:graphView];
        
        // save view so it can be erased later
        [_graphCacheViews addObject:graphView];
    }
}

- (void)removeGraphs{
    for (NSView *graphCacheView in _graphCacheViews){
        [graphCacheView removeFromSuperview];
    }
    
    // remove all objects
    [_graphCacheViews removeAllObjects];
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
        if ((object == _page) || ([_page containsObject:object])){
            // update textboxes
            [self updateElements];
            
            [self setNeedsDisplay:TRUE];
        }
    }
}

#pragma mark elements
- (void)updateElements{
#warning worksheet elements
    // remove
    [self removeTextboxes];
    [self removeGraphs];
    [self removeLines];
    [self removeExpressions];
    
    // draw
    [self drawTextboxes];
    [self drawGraphs];
    [self drawLines];
    [self drawExpressions];
}

#pragma mark textboxes
- (void)drawTextboxes{
    // get all textboxes for current page
    NSArray *textboxes = [[_page textboxes] allObjects];
    EDPageViewContainerTextView *textView;
    
    // for each graph create a graph view
    for (EDTextbox *textbox in textboxes){
        textView = [[EDPageViewContainerTextView alloc] initWithFrame:[self bounds] textbox:textbox context:_context];
        
        [self addSubview:textView];
        
        // save view so it can be erased later
        [_textboxViews addObject:textView];
    }
}

- (void)removeTextboxes{
    //for (NSTextView *textView in _textboxViews){
    for (NSView *textView in _textboxViews){
        [textView removeFromSuperview];
    }
    
    // remove all objects
    [_textboxViews removeAllObjects];
}

@end
