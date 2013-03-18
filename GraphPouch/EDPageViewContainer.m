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
//#import "EDEquation.h"
#import "EDGraphView.h"
#import "EDGraph.h"
#import "EDLine.h"
#import "EDPageViewContainer.h"
#import "EDPageViewContainerGraphView.h"
#import "EDPageViewContainerGraphCacheView.h"
#import "EDPageViewContainerTextView.h"
#import "EDPage.h"
//#import "EDParser.h"
#import "EDTextbox.h"
#import "NSColor+Utilities.h"

@interface EDPageViewContainer()
- (NSMutableDictionary *)calculateGraphOrigin:(EDGraph *)graph height:(float)graphHeight width:(float)graphWidth xRatio:(float)xRatio yRatio:(float)yRatio;
- (void)onContextChanged:(NSNotification *)note;
//- (NSMutableDictionary *)calculateGridIncrement:(float)maxValue minValue:(float)minValue originRatio:(float)ratio length:(float)length scale:(int)scale;
//- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo width:(float)graphWidth height:(float)graphHeight graph:(EDGraph *)graph;
- (void)drawEquation:(EDEquation *)equation verticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo width:(float)graphWidth height:(float)graphHeight graph:(EDGraph *)graph xRatio:(float)xRatio yRatio:(float)yRatio;

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
//- (void)updateTextboxes;
@end

@implementation EDPageViewContainer

- (id)initWithFrame:(NSRect)frame page:(EDPage *)page
{
    self = [super initWithFrame:frame];
    if (self) {
        _page = page;
        _context = [page managedObjectContext];
        _textboxViews = [[NSMutableArray alloc] init];
        //_graphViews = [[NSMutableArray alloc] init];
        _graphCacheViews = [[NSMutableArray alloc] init];
        _lineViews = [[NSMutableArray alloc] init];
        
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

#pragma mark drawing
- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [self drawLines];
}

#pragma mark lines
- (void)drawLines{
    float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
    float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
    NSArray *lines = [[_page lines] allObjects];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [[NSColor blackColor] setStroke];
    
    for (EDLine *line in lines){
        [path setLineWidth:(yRatio * [line thickness])];
        [path moveToPoint:NSMakePoint(xRatio * [line locationX], yRatio *([line locationY] + EDWorksheetLineSelectionHeight/2))];
        [path lineToPoint:NSMakePoint(xRatio * ([line locationX] + [line elementWidth]), yRatio *([line locationY] + EDWorksheetLineSelectionHeight/2))];
    }
    
    [path stroke];
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
    // remove all textboxes
    [self removeTextboxes];
    [self removeGraphs];
    
    // draw textboxes
    [self drawTextboxes];
    [self drawGraphs];
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
