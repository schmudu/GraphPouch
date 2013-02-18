//
//  EDPrintView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDGraph.h"
#import "EDGraphView.h"
#import "EDGraphViewPrint.h"
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
@end

@implementation EDPrintView

- (id)initWithFrame:(NSRect)frame context:(NSManagedObjectContext *)context
{
    self = [super initWithFrame:frame];
    if (self) {
        _context = context;
        _elements = [[NSMutableArray alloc] init];
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
    // remove all subviews
    [self removeAllSubviews];
    
    // get all pages
    NSArray *pages = [EDPage getAllObjectsOrderedByPageNumber:_context];
    NSArray *graphs, *textboxes, *lines;
    EDGraphViewPrint *graphView;
    EDLineView *lineView;
    EDTextboxView *textboxView;
    int pageIndex = 0;
    // for each page draw worksheet elements
    for (EDPage *page in pages){
#warning worksheet elements
        // DRAW GRAPHS
        graphs = [[page graphs] allObjects];
        
        for (EDGraph *graph in graphs){
            // create graphViewPrint and add it to the view
            graphView = [[EDGraphViewPrint alloc] initWithFrame:NSMakeRect([graph locationX], pageIndex * EDWorksheetViewHeight + [graph locationY], [graph elementWidth], [graph elementHeight]) graphModel:(EDGraph *)graph];
            
            // add it to view
            [self addSubview:graphView];
            [_elements addObject:graphView];
        }
        
        // DRAW LINES
        lines = [[page lines] allObjects];
        
        for (EDLine *line in lines){
            // create lineViewPrint and add it to the view
            lineView = [[EDLineViewPrint alloc] initWithFrame:NSMakeRect([line locationX], pageIndex * EDWorksheetViewHeight + [line locationY], [line elementWidth], [line elementHeight]) lineModel:line];
            
            // add it to view
            [self addSubview:lineView];
            [_elements addObject:lineView];
        }
        
        // DRAW TEXTBOXES
        textboxes = [[page textboxes] allObjects];
        
        for (EDTextbox *textbox in textboxes){
            // create lineViewPrint and add it to the view
            textboxView = [[EDTextboxView alloc] initWithFrame:NSMakeRect([textbox locationX], pageIndex * EDWorksheetViewHeight + [textbox locationY], [textbox elementWidth], [textbox elementHeight]) textboxModel:textbox];
            
            // add it to view
            [self addSubview:textboxView];
            [_elements addObject:textboxView];
        }
        
        pageIndex++;
    }
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
@end
