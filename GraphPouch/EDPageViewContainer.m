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
#import "EDPageViewContainerImageView.h"
#import "EDPageViewContainerLineView.h"
#import "EDPageViewContainerTextView.h"
#import "EDPage.h"
#import "EDTextbox.h"
#import "EDTextboxView.h"
#import "NSColor+Utilities.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSMutableArray+EDElements.h"

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
- (void)drawExpression:(EDExpression *)expression;
- (void)removeExpression:(EDExpression *)expression;
- (void)updateExpression:(EDExpression *)expression;

// graphs
- (void)drawGraphs;
- (void)removeGraphs;
- (void)drawGraph:(EDGraph *)graph;
- (void)removeGraph:(EDGraph *)graph;
- (void)updateGraph:(EDGraph *)graph;

// images
- (void)drawImages;
- (void)drawImage:(EDImage *)image;
- (void)removeImages;
- (void)removeImage:(EDImage *)image;
- (void)updateImage:(EDImage *)image;

// lines
- (void)drawLines;
- (void)removeLines;
- (void)drawLine:(EDLine *)line;
- (void)removeLine:(EDLine *)line;
- (void)updateLine:(EDLine *)line;

// textboxes
- (void)drawTextboxes;
- (void)removeTextboxes;
- (void)drawTextbox:(EDTextbox *)textbox;
- (void)removeTextbox:(EDTextbox *)textbox;
- (void)updateTextbox:(EDTextbox *)textbox;
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
        _expressionViews = [[NSMutableArray alloc] init];
        _graphViews = [[NSMutableArray alloc] init];
        _imageViews = [[NSMutableArray alloc] init];
        _lineViews = [[NSMutableArray alloc] init];
        _textboxViews = [[NSMutableArray alloc] init];
        
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
    [[NSColor whiteColor] setFill];
    [NSBezierPath fillRect:[self bounds]];
}

#pragma mark expressions
- (void)drawExpressions{
    NSArray *expressions = [[_page expressions] allObjects];
    
    // for each graph create a graph view
    for (EDExpression *expression in expressions)
        [self drawExpression:expression];
}

- (void)drawExpression:(EDExpression *)expression{
    EDPageViewContainerExpressionView *expressionView = [[EDPageViewContainerExpressionView alloc] initWithFrame:[self bounds] expression:expression context:_context];
    
    [self addSubview:expressionView];
    
    // save view so it can be erased later
    [_expressionViews addObject:expressionView];
}

- (void)removeExpressions{
    for (NSView *expressionView in _expressionViews){
        [expressionView removeFromSuperview];
    }
    
    // remove all objects
    [_expressionViews removeAllObjects];
}

- (void)removeExpression:(EDExpression *)expression{
    for (EDPageViewContainerExpressionView *expressionView in _expressionViews){
        if ([expressionView expression] == expression){
            [expressionView removeFromSuperview];
            [_expressionViews removeObject:expressionView];
            return;
        }
    }
}

- (void)updateExpression:(EDExpression *)expression{
    [self removeExpression:expression];
    [self drawExpression:expression];
}

#pragma mark images
- (void)drawImages{
    NSArray *images = [[_page images] allObjects];
    //EDPageViewContainerImageView *imageView;
    
    // for each graph create a graph view
    for (EDImage *image in images)
        [self drawImage:image];
}

- (void)drawImage:(EDImage *)image{
        EDPageViewContainerImageView *imageView = [[EDPageViewContainerImageView alloc] initWithFrame:[self bounds] image:image context:_context];
        
        [self addSubview:imageView];
        
        // save view so it can be erased later
        [_imageViews addObject:imageView];
    
}

- (void)removeImages{
    for (NSView *imageView in _imageViews){
        [imageView removeFromSuperview];
    }
    
    // remove all objects
    [_imageViews removeAllObjects];
}

- (void)removeImage:(EDImage *)image{
    for (EDPageViewContainerImageView *imageView in _imageViews){
        if ([imageView image] == image){
            [imageView removeFromSuperview];
            [_imageViews removeObject:imageView];
            return;
        }
    }
}

- (void)updateImage:(EDImage *)image{
    [self removeImage:image];
    [self drawImage:image];
}

#pragma mark lines
- (void)drawLines{
    NSArray *lines = [[_page lines] allObjects];
    //EDPageViewContainerLineView *lineView;
    
    // for each graph create a graph view
    for (EDLine *line in lines)
        [self drawLine:line];
}

- (void)drawLine:(EDLine *)line{
        EDPageViewContainerLineView *lineView = [[EDPageViewContainerLineView alloc] initWithFrame:[self bounds] line:line context:_context];
        
        [self addSubview:lineView];
        
        // save view so it can be erased later
        [_lineViews addObject:lineView];
    
}

- (void)removeLines{
    for (NSView *lineView in _lineViews){
        [lineView removeFromSuperview];
    }
    
    // remove all objects
    [_lineViews removeAllObjects];
}

- (void)removeLine:(EDLine *)line{
    for (EDPageViewContainerLineView *lineView in _lineViews){
        if ([lineView line] == line){
            [lineView removeFromSuperview];
            [_lineViews removeObject:lineView];
            return;
        }
    }
}

- (void)updateLine:(EDLine *)line{
    [self removeLine:line];
    [self drawLine:line];
}

#pragma mark graphs
- (void)drawGraphs{
    NSArray *graphs = [[_page graphs] allObjects];
    //EDPageViewContainerGraphView *graphView;
    
    // for each graph create a graph view
    for (EDGraph *graph in graphs){
        [self drawGraph:graph];
        /*
        graphView = [[EDPageViewContainerGraphView alloc] initWithFrame:[self bounds] graph:graph context:_context];
        
        [self addSubview:graphView];
        
        // save view so it can be erased later
        [_graphViews addObject:graphView];
         */
    }
}

- (void)drawGraph:(EDGraph *)graph{
    EDPageViewContainerGraphView *graphView = [[EDPageViewContainerGraphView alloc] initWithFrame:[self bounds] graph:graph context:_context];
    
    [self addSubview:graphView];
    
    // save view so it can be erased later
    [_graphViews addObject:graphView];
}

- (void)removeGraphs{
    for (NSView *graphView in _graphViews){
        [graphView removeFromSuperview];
    }
    
    // remove all objects
    [_graphViews removeAllObjects];
}

- (void)removeGraph:(EDGraph *)graph{
    for (EDPageViewContainerGraphView *graphView in _graphViews){
        if ([graphView graph] == graph){
            [graphView removeFromSuperview];
            [_graphViews removeObject:graphView];
            return;
        }
    }
}

- (void)updateGraph:(EDGraph *)graph{
    [self removeGraph:graph];
    [self drawGraph:graph];
}

- (void)onContextChanged:(NSNotification *)note{
    // optimize the updating of drawing on the page view container
    NSMutableArray *deletedArray = [NSMutableArray arrayWithArray:[[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects]];
    NSMutableArray *insertedArray = [NSMutableArray arrayWithArray:[[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects]];
    NSMutableArray *updatedArray = [NSMutableArray arrayWithArray:[[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects]];
    
    // if any object was removed then remove its view
    for (NSManagedObject *object in updatedArray){
        //if ((object == _page) || ([_page containsObject:object])){
        // if page object was deleted and the array was incremented then objects on that page were deleted
        if ((object == _page) && ([deletedArray count]>0)){
            // if deleted count is greater than 0 then an image was removed
            //if (([object isKindOfClass:[EDPage class]]) && ([deletedArray count]>0)){
                // iterate through deleted array and delete all objects
                for (NSManagedObject *deletedObject in deletedArray){
#warning worksheet elements
                    // if expression relationship was changed then an expression was deleted
                    if ([[object changedValues] objectForKey:EDPageAttributeExpressions]){
                        EDExpression *objectExpression = [deletedArray getAndRemoveObjectExpression];
                        if (objectExpression)
                            [self removeExpression:objectExpression];
                    }
                    
                    // if graph relationship was changed then a graph was deleted
                    if ([[object changedValues] objectForKey:EDPageAttributeGraphs]){
                        EDGraph *objectGraph = [deletedArray getAndRemoveObjectGraph];
                        if (objectGraph)
                            [self removeGraph:objectGraph];
                    }
                    
                    // if image relationship was changed then an image was deleted
                    if ([[object changedValues] objectForKey:EDPageAttributeImages]){
                        EDImage *objectImage = [deletedArray getAndRemoveObjectImage];
                        if (objectImage)
                            [self removeImage:objectImage];
                    }
                    
                    // if line relationship was changed then a line was deleted
                    if ([[object changedValues] objectForKey:EDPageAttributeLines]){
                        EDLine *objectLine = [deletedArray getAndRemoveObjectLine];
                        if (objectLine)
                            [self removeLine:objectLine];
                    }
                    
                    // if textbox relationship was changed then a line was deleted
                    if ([[object changedValues] objectForKey:EDPageAttributeTextboxes]){
                        EDTextbox *objectTextbox = [deletedArray getAndRemoveObjectTextbox];
                        if (objectTextbox)
                            [self removeTextbox:objectTextbox];
                    }
                }
            //}
        }
        else if([_page containsObject:object]){
            // an object on the page was updated
            if ([object isKindOfClass:[EDExpression class]])
                [self updateExpression:(EDExpression *)object];
            else if ([object isKindOfClass:[EDGraph class]])
                [self updateGraph:(EDGraph *)object];
            else if ([object isKindOfClass:[EDImage class]])
                [self updateImage:(EDImage *)object];
            else if ([object isKindOfClass:[EDLine class]])
                [self updateLine:(EDLine *)object];
            else if ([object isKindOfClass:[EDTextbox class]])
                [self updateTextbox:(EDTextbox *)object];
        }
    }
    
    // draw inserted objects
    for (NSManagedObject *object in insertedArray){
        // an object on the page was updated
        if ([object isKindOfClass:[EDExpression class]])
            [self drawExpression:(EDExpression *)object];
        else if ([object isKindOfClass:[EDGraph class]])
            [self drawGraph:(EDGraph *)object];
        else if ([object isKindOfClass:[EDImage class]])
            [self drawImage:(EDImage *)object];
        else if ([object isKindOfClass:[EDLine class]])
            [self drawLine:(EDLine *)object];
        else if ([object isKindOfClass:[EDTextbox class]])
            [self drawTextbox:(EDTextbox *)object];
    }
}

#pragma mark elements
- (void)updateElements{
#warning worksheet elements
    // remove
    [self removeTextboxes];
    [self removeGraphs];
    [self removeImages];
    [self removeLines];
    [self removeExpressions];
    
    // draw
    [self drawTextboxes];
    [self drawGraphs];
    [self drawImages];
    [self drawLines];
    [self drawExpressions];
}

#pragma mark textboxes
- (void)drawTextboxes{
    // get all textboxes for current page
    NSArray *textboxes = [[_page textboxes] allObjects];
    
    // for each graph create a graph view
    for (EDTextbox *textbox in textboxes)
        [self drawTextbox:textbox];
}

- (void)drawTextbox:(EDTextbox *)textbox{
    EDPageViewContainerTextView *textView = [[EDPageViewContainerTextView alloc] initWithFrame:[self bounds] textbox:textbox context:_context];
    
    [self addSubview:textView];
    
    // save view so it can be erased later
    [_textboxViews addObject:textView];
}

- (void)removeTextboxes{
    //for (NSTextView *textView in _textboxViews){
    for (NSView *textView in _textboxViews){
        [textView removeFromSuperview];
    }
    
    // remove all objects
    [_textboxViews removeAllObjects];
}

- (void)removeTextbox:(EDTextbox *)textbox{
    for (EDPageViewContainerTextView *textboxView in _textboxViews){
        if ([textboxView textbox] == textbox){
            [textboxView removeFromSuperview];
            [_textboxViews removeObject:textboxView];
            return;
        }
    }
}

- (void)updateTextbox:(EDTextbox *)textbox{
    [self removeTextbox:textbox];
    [self drawTextbox:textbox];
}
@end
