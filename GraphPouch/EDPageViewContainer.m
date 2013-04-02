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
#import "NSColor+Utilities.h"

@interface EDPageViewContainer()
- (void)onContextChanged:(NSNotification *)note;

// context menu
- (void)onMenuPageSelect:(id)sender;
- (void)onMenuPageDeselect:(id)sender;

// elements
- (void)updateElements;

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
#pragma mark context menu
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
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
    /*
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
     
     if ([[menuItem title] isEqualToString:EDContextMenuPageAdd]){
     return TRUE;
     }
     
     if ([[menuItem title] isEqualToString:EDContextMenuPagesSelectAll]){
     NSArray *selectedPages = [EDPage getAllSelectedObjects:_context];
     NSArray *allPages = [EDPage getAllObjects:_context];
     
     if ([selectedPages count] == [allPages count])
     return FALSE;
     else
     return TRUE;
     }
     
     if ([[menuItem title] isEqualToString:EDContextMenuPagesDeselectAll]){
     NSArray *selectedPages = [EDPage getAllSelectedObjects:_context];
     
     if ([selectedPages count] > 0)
     return TRUE;
     else
     return FALSE;
     }
     
     if (([[menuItem title] isEqualToString:EDContextMenuPagesDelete]) || ([[menuItem title] isEqualToString:EDContextMenuPagesDeletePlural])){
     NSArray *selectedPages = [EDPage getAllSelectedObjects:_context];
     NSArray *allPages = [EDPage getAllObjects:_context];
     
     if (([selectedPages count] > 0) && (([allPages count] - [selectedPages count]) > 0))
     return TRUE;
     else
     return FALSE;
     }
     
     if (([[menuItem title] isEqualToString:EDContextMenuPagesCopy]) || ([[menuItem title] isEqualToString:EDContextMenuPagesCopyPlural])){
     NSArray *selectedPages = [EDPage getAllSelectedObjects:_context];
     
     if ([selectedPages count] > 0)
     return TRUE;
     else
     return FALSE;
     }
     
     
     if (([[menuItem title] isEqualToString:EDContextMenuPagesPaste]) || ([[menuItem title] isEqualToString:EDContextMenuPagesPastePlural])){
     NSArray *classes = [NSArray arrayWithObject:[EDPage class]];
     NSArray *pages = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:nil];
     
     if ([pages count] > 0)
     return TRUE;
     else
     return FALSE;
     }
     
     
     if ([[menuItem title] isEqualToString:EDContextMenuPagesPageNext]){
     return TRUE;
     }
     
     if ([[menuItem title] isEqualToString:EDContextMenuPagesPagePrevious]){
     return TRUE;
     }
     */
    
    return [super validateMenuItem:menuItem];
}

- (NSMenu *)menuForEvent:(NSEvent *)event{
    NSMenu *returnMenu = [[NSMenu alloc] init];
    
    [returnMenu addItemWithTitle:EDContextMenuPageDeselect action:@selector(onMenuPageDeselect:) keyEquivalent:@""];
    [returnMenu addItemWithTitle:EDContextMenuPageSelect action:@selector(onMenuPageSelect:) keyEquivalent:@""];
    /*
     // add/remove page
     NSMenuItem *menuPageAdd = [[NSMenuItem alloc] initWithTitle:EDContextMenuPageAdd action:@selector(onMenuPageAdd:) keyEquivalent:@"p"];
     [menuPageAdd setKeyEquivalentModifierMask:NSControlKeyMask];
     [returnMenu addItem:menuPageAdd];
     
     // menu depends on how many pages are selected and in the pasteboard
     NSArray *pagesSelected = [EDCoreDataUtility getAllSelectedPages:_context];
     
     NSArray *classes = [NSArray arrayWithObject:[EDPage class]];
     NSArray *pagesBuffered = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:nil];
     BOOL multiplePagesBuffered = FALSE;
     
     if ([pagesBuffered count] > 1)
     multiplePagesBuffered = TRUE;
     
     // based on the number of pages selected and what's buffered set the menu
     if ([pagesSelected count] > 1){
     [returnMenu addItemWithTitle:EDContextMenuPagesCopyPlural action:@selector(onMenuPagesCopy:) keyEquivalent:@"c"];
     if (multiplePagesBuffered)
     [returnMenu addItemWithTitle:EDContextMenuPagesPastePlural action:@selector(onMenuPagesPaste:) keyEquivalent:@"v"];
     else
     [returnMenu addItemWithTitle:EDContextMenuPagesPaste action:@selector(onMenuPagesPaste:) keyEquivalent:@"v"];
     
     [returnMenu addItemWithTitle:EDContextMenuPagesDeletePlural action:@selector(onMenuPagesDelete:) keyEquivalent:@""];
     }
     else{
     [returnMenu addItemWithTitle:EDContextMenuPagesCopy action:@selector(onMenuPagesCopy:) keyEquivalent:@"c"];
     if (multiplePagesBuffered)
     [returnMenu addItemWithTitle:EDContextMenuPagesPastePlural action:@selector(onMenuPagesPaste:) keyEquivalent:@"v"];
     else
     [returnMenu addItemWithTitle:EDContextMenuPagesPaste action:@selector(onMenuPagesPaste:) keyEquivalent:@"v"];
     
     [returnMenu addItemWithTitle:EDContextMenuPagesDelete action:@selector(onMenuPagesDelete:) keyEquivalent:@""];
     }
     
     // selection
     [returnMenu addItem:[NSMenuItem separatorItem]];
     [returnMenu addItemWithTitle:EDContextMenuPagesSelectAll action:@selector(onMenuPagesSelectAll:) keyEquivalent:@"a"];
     [returnMenu addItemWithTitle:EDContextMenuPagesDeselectAll action:@selector(onMenuPagesDeselectAll:) keyEquivalent:@"d"];
     
     // navigation
     [returnMenu addItem:[NSMenuItem separatorItem]];
     NSMenuItem *menuPagePreviousNext = [[NSMenuItem alloc] initWithTitle:EDContextMenuPagesPageNext action:@selector(onMenuPagesGoToPageNext:) keyEquivalent:@"]"];
     [menuPagePreviousNext setKeyEquivalentModifierMask:NSShiftKeyMask|NSCommandKeyMask];
     [returnMenu addItem:menuPagePreviousNext];
     
     NSMenuItem *menuPagePreviousPage = [[NSMenuItem alloc] initWithTitle:EDContextMenuPagesPagePrevious action:@selector(onMenuPagesGoToPagePrevious:) keyEquivalent:@"["];
     [menuPagePreviousPage setKeyEquivalentModifierMask:NSShiftKeyMask|NSCommandKeyMask];
     [returnMenu addItem:menuPagePreviousPage];
     */
    return returnMenu;
}

- (void)onMenuPageSelect:(id)sender{
    [EDCoreDataUtility setPageAsSelected:_page context:_context];
}

- (void)onMenuPageDeselect:(id)sender{
    [EDCoreDataUtility setPageAsDeselected:_page context:_context];
}

/*
- (void)onMenuPageAdd:(id)sender{
    [[[self window] firstResponder] doCommandBySelector:@selector(pageAdd:)];
}

- (void)onMenuPagesSelectAll:(id)sender{
    [EDCoreDataUtility selectAllPages:_context];
}

- (void)onMenuPagesDeselectAll:(id)sender{
    [EDCoreDataUtility deselectAllPages:_context];
}

- (void)onMenuPagesCopy:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutCopy object:self];
}

- (void)onMenuPagesDelete:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesDeletePressed object:self];
}

- (void)onMenuPagesGoToPageNext:(id)sender{
    [EDCoreDataUtility gotoPageNext:_context];
}

- (void)onMenuPagesGoToPagePrevious:(id)sender{
    [EDCoreDataUtility gotoPagePrevious:_context];
    
}

- (void)onMenuPagesPaste:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesPastePressed object:self];
}*/

#pragma mark drawing
- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
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
    
}

#pragma mark graphs
- (void)drawGraphs{
    NSArray *graphs = [[_page graphs] allObjects];
    EDPageViewContainerGraphView *graphView;
    EDPageViewContainerGraphCacheView *graphCacheView;
    NSImage *graphImage;
    
    // for each graph create a graph view
    for (EDGraph *graph in graphs){
        graphView = [[EDPageViewContainerGraphView alloc] initWithFrame:[self bounds] graph:graph context:_context];
        
        // create image
        graphImage = [[NSImage alloc] initWithData:[graphView dataWithPDFInsideRect:[graphView bounds]]];
        
        // create cache image that only needs to draw on update
        graphCacheView = [[EDPageViewContainerGraphCacheView alloc] initWithFrame:[self bounds] graphImage:graphImage];
        [self addSubview:graphCacheView];
        
        // save view so it can be erased later
        [_graphCacheViews addObject:graphCacheView];
    }
}

- (void)removeGraphs{
    for (NSView *graphCacheView in _graphCacheViews){
        [graphCacheView removeFromSuperview];
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
    
    // draw
    [self drawTextboxes];
    [self drawGraphs];
    [self drawLines];
}

#pragma mark textboxes
- (void)drawTextboxes{
    // get all textboxes for current page
    NSArray *textboxes = [[_page textboxes] allObjects];
    NSTextView *newTextView;
    
    // calculate ratio
    float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
    float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
    
    // for each textbox draw it on the view
    for (EDTextbox *textbox in textboxes){
        newTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, [textbox elementWidth], [textbox elementHeight])];
        [newTextView setDrawsBackground:FALSE];
        
        // set container size, controls clipping
        [[newTextView textContainer] setContainerSize:NSMakeSize([textbox elementWidth], [textbox elementHeight])];
        
        // add text
        if ([textbox textValue]){
            // insert saved data
            [newTextView insertText:[textbox textValue]];
            
            [newTextView setEditable:FALSE];
            [newTextView setSelectable:FALSE];
            [newTextView setDrawsBackground:FALSE];
            
            // format the text accordingly
            [[textbox textValue] enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0,[[textbox textValue] length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange blockRange, BOOL *stop) {
                NSFont *modifiedFont;
                if (value != nil){
                    // go through the string and update the characters based on the range
                    // remove default
                    [[newTextView textStorage] removeAttribute:NSFontAttributeName range:blockRange];
                    
                    // need to resize the font according to ratio
                    //modifiedFont = [[NSFontManager sharedFontManager] convertFont:(NSFont *)value toSize:[(NSFont *)value pointSize] * xRatio + 1];
                    modifiedFont = [[NSFontManager sharedFontManager] convertFont:(NSFont *)value toSize:[(NSFont *)value pointSize]];
                    
                    // add custom attributes
                    [[newTextView textStorage] addAttribute:NSFontAttributeName value:modifiedFont range:blockRange];
                }
            }];
        }
        
        
        // create image
        NSImage *textImage = [[NSImage alloc] initWithData:[newTextView dataWithPDFInsideRect:[newTextView bounds]]];
        EDPageViewContainerTextView *textView = [[EDPageViewContainerTextView alloc] initWithFrame:[self bounds] textImage:textImage xRatio:xRatio yRatio:yRatio];
        
        [self addSubview:textView];
        
        // position it
        [textView setFrameOrigin:NSMakePoint(xRatio * [textbox locationX], yRatio * [textbox locationY])];
        
        // save view so it can be erased later
        [_textboxViews addObject:textView];
    }
}

- (void)removeTextboxes{
    //for (NSTextView *textView in _textboxViews){
    for (NSView *textView in _textboxViews){
        [textView removeFromSuperview];
    }
}

@end
