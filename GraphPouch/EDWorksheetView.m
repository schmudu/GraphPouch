//
//  EDWorksheetView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDDocument.h"
#import "EDCoreDataUtility.h"
#import "EDConstants.h"
#import "EDWorksheetView.h"
#import "EDGraphView.h"
#import "EDGraph.h"

@interface EDWorksheetView()
- (void)drawGraph:(EDGraph *)graph;
- (void)onContextChanged:(NSNotification *)note;
- (void)onGraphMouseDown:(NSNotification *)note;
- (void)onGraphMouseDragged:(NSNotification *)note;
- (void)onGraphMouseUp:(NSNotification *)note;
@end

@implementation EDWorksheetView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        _context = [_coreData context];
        
        //NSLog(@"creating worksheet view:%@ with context:%@", self, _context);
        
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

#pragma mark Drawing
- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawLoadedObjects{
    // this draws the objects loaded from the persistence store
    NSArray *graphs = [_coreData getAllGraphs];
    for (EDGraph *graph in graphs){
        [self drawGraph:graph];
        //NSLog(@"going to draw: %@", graph);
    }
    
#warning need to add loops for labels and lines once we implement those
    
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

- (void)drawGraph:(EDGraph *)graph{
    EDGraphView *graphView = [[EDGraphView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40) graphModel:graph];
    
    // listen to graph
    [_nc addObserver:self selector:@selector(onGraphSelectedDeselectOtherGraphs:) name:EDEventUnselectedGraphClickedWithoutModifier object:graphView];
    [_nc addObserver:self selector:@selector(onGraphMouseDown:) name:EDEventMouseDown object:graphView];
    [_nc addObserver:self selector:@selector(onGraphMouseDragged:) name:EDEventMouseDragged object:graphView];
    [_nc addObserver:self selector:@selector(onGraphMouseUp:) name:EDEventMouseDragged object:graphView];
    
    // set location
    //[graphView setFrameOrigin:NSMakePoint([graph locationX], [graph locationY])];
    [graphView setFrameOrigin:NSMakePoint([[graph valueForKey:EDElementAttributeLocationX] floatValue], [[graph valueForKey:EDElementAttributeLocationY] floatValue])];
    [self addSubview:graphView];
    [self setNeedsDisplay:TRUE];
}

#pragma mark mouse behavior
- (void)mouseDown:(NSEvent *)theEvent{
    //post notification
    [_nc postNotificationName:EDEventWorksheetClicked object:self];
}

#pragma mark Listeners
- (void)onContextChanged:(NSNotification *)note{
    //EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    //NSManagedObjectContext *context = [coreData context];
    //NSLog(@"context that delivered message: %@ worksheet view:%@", _context, self);
    //Graph *myGraph = [note object];
    //NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    //NSArray *deletedArray = [[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects];
    //NSLog(@"new graph added: %@ count:%ld", [[[note userInfo] objectForKey:NSInsertedObjectsKey] class], [insertedArray count]);
    //NSLog(@"new graph updated: %@ count:%ld", [[[note userInfo] objectForKey:NSUpdatedObjectsKey] class], [updatedArray count]);
    //NSLog(@"new graph deleted: %@ count:%ld", [[[note userInfo] objectForKey:NSDeletedObjectsKey] class], [deletedArray count]);
    // draw graphs that were added
    NSArray *insertedArray = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    for (EDGraph *myGraph in insertedArray){
        //NSLog(@"going to insert graph: %@", myGraph);
        [self drawGraph:myGraph];
    }
    
    // remove graphs that were deleted
    NSArray *deletedArray = [[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects];
    for (EDGraph *myGraph in deletedArray){
        //[self drawGraph:myGraph];
        //NSLog(@"going to remove graph: %@", myGraph);
        [self removeGraphView:myGraph];
    }
}

- (void)removeGraphView:(EDGraph *)graph{
    for (EDGraphView *graphView in [self subviews]){
        if ([graphView dataObj] == graph){
            [graphView removeFromSuperview];
        
            // remove listener
            [_nc removeObserver:self name:EDEventUnselectedGraphClickedWithoutModifier object:graphView];
            [_nc removeObserver:self name:EDEventMouseDown object:graphView];
            [_nc removeObserver:self name:EDEventMouseDragged object:graphView];
            [_nc removeObserver:self name:EDEventMouseUp object:graphView];
        }
    }
}

- (void)onGraphSelectedDeselectOtherGraphs:(NSNotification *)note{
    [_nc postNotificationName:EDEventUnselectedGraphClickedWithoutModifier object:self];
}

- (void)onGraphMouseDown:(NSNotification *)note{
    // notify all selectd subviews that mouse down was pressed
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (EDWorksheetElementView *myElement in [self subviews]){
        if([selectedElements containsObject:[myElement dataObj]]){
            //NSLog(@"we have a selected element: event: %@", [[note userInfo] valueForKey:EDEventKey]);
            // notify element that of mouse down
            [myElement mouseDownBySelection:[[note userInfo] valueForKey:EDEventKey]];
        }
    }
}

- (void)onGraphMouseDragged:(NSNotification *)note{
    // notify all selectd subviews that mouse down was pressed
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (EDWorksheetElementView *myElement in [self subviews]){
        if([selectedElements containsObject:[myElement dataObj]]){
            // notify element that of mouse dragged
            [myElement mouseDraggedBySelection:[[note userInfo] valueForKey:EDEventKey]];
        }
    }
}

- (void)onGraphMouseUp:(NSNotification *)note{
    // notify all selectd subviews that mouse down was pressed
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (EDWorksheetElementView *myElement in [self subviews]){
        if([selectedElements containsObject:[myElement dataObj]]){
            // notify element that of mouse dragged
            [myElement mouseUpBySelection:[[note userInfo] valueForKey:EDEventKey]];
        }
    }
}
@end
