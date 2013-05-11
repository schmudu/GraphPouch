//
//  EDPrintView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDExpressionView.h"
#import "EDGraph.h"
#import "EDGraphView.h"
#import "EDGraphViewPrint.h"
#import "EDImage.h"
#import "EDImageView.h"
#import "EDLine.h"
#import "EDLineView.h"
#import "EDLineViewPrint.h"
#import "EDPrintView.h"
#import "EDPage.h"
#import "EDTextbox.h"
#import "EDTextboxView.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDPrintView()
- (void)removeAllSubviews;
- (void)compareLayers;
@end

@implementation EDPrintView

- (id)initWithFrame:(NSRect)frame context:(NSManagedObjectContext *)context
{
    self = [super initWithFrame:frame];
    if (self) {
        _context = context;
        _elements = [[NSMutableArray alloc] init];
        
        // remove all subviews
        [self removeAllSubviews];
        
        // get all pages
        NSArray *pages = [EDPage getAllObjectsOrderedByPageNumber:_context];
        NSArray *expressions, *graphs, *images, *textboxes, *lines;
        EDGraphViewPrint *graphView;
        EDImageView *imageView;
        EDLineView *lineView;
        EDTextboxView *textboxView;
        EDExpressionView *expressionView;
        
        int pageIndex = 0;
        // for each page draw worksheet elements
        for (EDPage *page in pages){
#warning worksheet elements
#warning could potentially remove all 'PrintView' classes
            // DRAW EXPRESSION
            expressions = [[page expressions] allObjects];
            
            for (EDExpression *expression in expressions){
                // create expressionView and add it to the view
                expressionView = [[EDExpressionView alloc] initWithFrame:NSMakeRect([expression locationX], pageIndex * EDWorksheetViewHeight + [expression locationY], [expression elementWidth], [expression elementHeight]) expression:expression drawSelection:FALSE];
                
                // add it to view
                [self addSubview:expressionView];
                [_elements addObject:expressionView];
            }
            
            // DRAW GRAPHS
            graphs = [[page graphs] allObjects];
            
            for (EDGraph *graph in graphs){
                // create graphViewPrint and add it to the view
                graphView = [[EDGraphViewPrint alloc] initWithFrame:NSMakeRect([graph locationX], pageIndex * EDWorksheetViewHeight + [graph locationY], [graph elementWidth], [graph elementHeight]) graphModel:(EDGraph *)graph];
                
                // add it to view
                [self addSubview:graphView];
                [_elements addObject:graphView];
            }
            
            // DRAW IMAGES
            images = [[page images] allObjects];
            
            for (EDImage *image in images){
                // create graphViewPrint and add it to the view
                imageView = [[EDImageView alloc] initWithFrame:NSMakeRect([image locationX], pageIndex * EDWorksheetViewHeight + [image locationY], [image elementWidth], [image elementHeight]) imageModel:image];
                
                // add it to view
                [self addSubview:imageView];
                [_elements addObject:imageView];
            }
            
            // DRAW LINES
            lines = [[page lines] allObjects];
            
            for (EDLine *line in lines){
                // create lineViewPrint and add it to the view
                lineView = [[EDLineViewPrint alloc] initWithFrame:NSMakeRect([line locationX], pageIndex * EDWorksheetViewHeight + [line locationY], [line elementWidth], [line elementHeight]) lineModel:line drawSelection:FALSE];
                
                // add it to view
                [self addSubview:lineView];
                [_elements addObject:lineView];
            }
            
            // DRAW TEXTBOXES
            textboxes = [[page textboxes] allObjects];
            
            for (EDTextbox *textbox in textboxes){
                // create lineViewPrint and add it to the view
                textboxView = [[EDTextboxView alloc] initWithFrame:NSMakeRect([textbox locationX], pageIndex * EDWorksheetViewHeight + [textbox locationY], [textbox elementWidth], [textbox elementHeight]) textboxModel:textbox drawSelection:FALSE];
                
                // add it to view
                [self addSubview:textboxView];
                [_elements addObject:textboxView];
            }
            
            pageIndex++;
        }
        
        // layer elements
        [self compareLayers];
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)removeAllSubviews{
    // iterate through views and remove them
    for (NSView *view in _elements){
        [view removeFromSuperview];
    }
}
- (void)drawRect:(NSRect)dirtyRect
{
    // drawing
    // layers
    //[self compareLayers:nil];
}


- (BOOL)knowsPageRange:(NSRange *)rptr{
    NSArray *pages = [EDPage getAllObjects:_context];
    rptr->location = 1;
    rptr->length = [pages count];
    //rptr->length = 1;
    return TRUE;
}

- (NSRect)rectForPage:(NSInteger)i{
    // start at 0 instead of 1
    return NSMakeRect(0, (i-1) * EDWorksheetViewHeight, EDWorksheetViewWidth, EDWorksheetViewHeight);
}

#pragma mark layering
NSComparisonResult viewComparePrintElements(NSView *firstView, NSView *secondView, void *context) {
    // order view by isSelected
    EDWorksheetElementView *firstElement;
    EDWorksheetElementView *secondElement;
    
    if ([firstView isKindOfClass:[EDWorksheetElementView class]]) {
        firstElement = (EDWorksheetElementView *)firstView;
        if ([secondView isKindOfClass:[EDWorksheetElementView class]]) {
            secondElement = (EDWorksheetElementView *)secondView;
            // set ordering
            //NSLog(@"first z-index:%d second z-index:%d", [[[firstElement dataObj] zIndex] intValue], [[[secondElement dataObj] zIndex] intValue]);
            if ([[[firstElement dataObj] zIndex] intValue] > [[[secondElement dataObj] zIndex] intValue]){
                return NSOrderedDescending;
            }
        }
    }
    return NSOrderedAscending;
}

- (void)compareLayers{
    //NSLog(@"comparing layers.");
    [self sortSubviewsUsingFunction:&viewComparePrintElements context:nil];
}
@end
