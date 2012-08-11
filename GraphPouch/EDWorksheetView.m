//
//  EDWorksheetView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDConstants.h"
#import "EDWorksheetView.h"
#import "EDGraphView.h"
#import "Graph.h"

@interface EDWorksheetView()
- (void)removeSelectedElement:(NSString *)id andAddElements:(NSMutableDictionary *)undoElements;
@end

@implementation EDWorksheetView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
        _context = [coreData context];
        
        NSLog(@"creating worksheet view:%@ with context:%@", self, _context);
        
        // listen
        _nc = [NSNotificationCenter defaultCenter];
        [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

/*
- (void)loadDataFromManagedObjectContext{
    //EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
#warning need to alter this to allow the drawing different types of elements
    //draw graphs
    //NSLog(@"load data from managed context: %@", [coreData context]);
    
    // load data
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //NSEntityDescription *entity = [NSEntityDescription entityForName:@"Graph" inManagedObjectContext:[coreData context]];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Graph" inManagedObjectContext:_context];
    [request setEntity:entity];
    
    NSArray *results = [_context executeFetchRequest:request error:&error];    
    //NSLog(@"results: %ld", [results count]);
    for (Graph *elem in results){
        //draw graph
        [self drawGraph:elem];
    }
    //NSLog(@"edworksheetview load data from amanaged object context.");
}*/

#pragma mark Drawing
- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:bounds];
    
    for(EDGraphView *graph in [self subviews]){
        [graph setNeedsDisplay:TRUE];
    }
}

- (void)drawGraph:(Graph *)graph{
    EDGraphView *graphView = [[EDGraphView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40) graphModel:graph];
    
    // set location
    [graphView setFrameOrigin:NSMakePoint([graph locationX], [graph locationY])];
    [self addSubview:graphView];
    [self setNeedsDisplay:TRUE];
}

#pragma mark mouse behavior
- (void)mouseDown:(NSEvent *)theEvent{
    //post notification
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [_nc postNotificationName:EDEventWorksheetClicked object:self];
}

#pragma mark Listeners
- (void)onContextChanged:(NSNotification *)note{
    //EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    //NSManagedObjectContext *context = [coreData context];
    NSLog(@"context that delivered message: %@ worksheet view:%@", _context, self);
    //Graph *myGraph = [note object];
    //NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    //NSArray *deletedArray = [[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects];
    //NSLog(@"new graph added: %@ count:%ld", [[[note userInfo] objectForKey:NSInsertedObjectsKey] class], [insertedArray count]);
    //NSLog(@"new graph updated: %@ count:%ld", [[[note userInfo] objectForKey:NSUpdatedObjectsKey] class], [updatedArray count]);
    //NSLog(@"new graph deleted: %@ count:%ld", [[[note userInfo] objectForKey:NSDeletedObjectsKey] class], [deletedArray count]);
    // draw graphs that were added
    NSArray *insertedArray = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    for (Graph *myGraph in insertedArray){
        [self drawGraph:myGraph];
    }
}

#pragma mark selection
- (void)onWorksheetClicked:(NSNotification *)note{
    [_nc postNotificationName:EDEventWorksheetClicked object:self];
}
@end
