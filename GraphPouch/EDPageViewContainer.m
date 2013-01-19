//
//  EDPageViewContainer.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/19/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPageViewContainer.h"
#import "EDPage.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"
#import "EDCoreDataUtility+Graphs.h"
#import "EDGraphView.h"
#import "EDGraph.h"

@interface EDPageViewContainer()
- (void)onContextChanged:(NSNotification *)note;
@end

@implementation EDPageViewContainer

- (id)initWithFrame:(NSRect)frame page:(EDPage *)page
{
    self = [super initWithFrame:frame];
    if (self) {
        _page = page;
        _context = [page managedObjectContext];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    
    return self;
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
    [self drawGraphs];
}

- (void)drawGraphs{
    NSArray *graphs = [EDCoreDataUtility getGraphsForPage:_page context:_context];
    float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
    float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
    float graphWidth, graphHeight;
    NSBezierPath *path;
    
    [[NSColor colorWithHexColorString:EDGraphBorderColor] setStroke];
    
    // for each of the graphs draw them
    for (EDGraph *graph in graphs){
        // draw graph in that position
        graphWidth = xRatio * ([graph elementWidth] - [EDGraphView graphMargin] * 2);
        graphHeight = xRatio * ([graph elementHeight] - [EDGraphView graphMargin] * 2);
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(xRatio * ([EDGraphView graphMargin] + [graph locationX]),
                                                           yRatio * ([graph locationY] + [EDGraphView graphMargin]),
                                                           graphWidth,
                                                           graphHeight)];
        [path setLineWidth:EDPageViewGraphBorderLineWidth];
        [path stroke];
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
            [self setNeedsDisplay:TRUE];
        }
    }
}
@end
