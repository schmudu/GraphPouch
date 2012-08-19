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
- (void)onElementMouseDown:(NSNotification *)note;
- (void)onElementMouseDragged:(NSNotification *)note;
- (void)onElementMouseUp:(NSNotification *)note;
@end

@implementation EDWorksheetView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        _context = [_coreData context];
        
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
    for (EDGraph *myGraph in graphs){
        [self drawGraph:myGraph];
    }
    
#warning add other elements here
    
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
    EDGraphView *graphView = [[EDGraphView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40) graphModel:(EDGraph *)graph];
    
    // listen to graph
    // NOTE: any listeners you add here, remove them in method 'removeElementView'
    [_nc addObserver:self selector:@selector(onGraphSelectedDeselectOtherGraphs:) name:EDEventUnselectedGraphClickedWithoutModifier object:graphView];
    [_nc addObserver:self selector:@selector(onElementMouseDown:) name:EDEventMouseDown object:graphView];
    [_nc addObserver:self selector:@selector(onElementMouseDragged:) name:EDEventMouseDragged object:graphView];
    [_nc addObserver:self selector:@selector(onElementMouseUp:) name:EDEventMouseUp object:graphView];
    
    // set location
    [graphView setFrameOrigin:NSMakePoint([[graph valueForKey:EDElementAttributeLocationX] floatValue], [[graph valueForKey:EDElementAttributeLocationY] floatValue])];
    [self addSubview:graphView];
    [self setNeedsDisplay:TRUE];
}

#pragma mark keyboard
- (BOOL)acceptsFirstResponder{
    return TRUE;
}

- (void)keyDown:(NSEvent *)theEvent{
    NSUInteger flags = [theEvent modifierFlags];
    if(flags == EDKeyModifierNone && [theEvent keyCode] == EDKeycodeDelete){
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventDeleteKeyPressedWithoutModifiers object:self];
    }
}

#pragma mark mouse behavior
- (void)mouseDown:(NSEvent *)theEvent{
    //post notification
    [_nc postNotificationName:EDEventWorksheetClicked object:self];
}

#pragma mark Listeners
- (void)onContextChanged:(NSNotification *)note{
    NSArray *insertedArray = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    
    for (EDElement *myElement in insertedArray){
        if ([[myElement className] isEqualToString:EDEntityNameGraph]) {
            [self drawGraph:(EDGraph *)myElement];
        }
#warning add other elements here, need drawLabel, drawLine
             
    }
    
    // remove graphs that were deleted
    NSArray *deletedArray = [[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects];
    for (EDElement *myElement in deletedArray){
        [self removeElementView:myElement];
    }
}

- (void)removeElementView:(EDElement *)element{
    BOOL found = FALSE;
    int i = 0;
    EDWorksheetElementView *currentElement;
    //for (EDGraphView *graphView in [self subviews]){
    while (!found && i<[[self subviews] count]){
        currentElement = (EDWorksheetElementView *)[[self subviews] objectAtIndex:i];
        if ([currentElement dataObj] == element){
            found = TRUE;
            [currentElement removeFromSuperview];
        
            // remove listener
            [_nc removeObserver:self name:EDEventUnselectedGraphClickedWithoutModifier object:currentElement];
            [_nc removeObserver:self name:EDEventMouseDown object:currentElement];
            [_nc removeObserver:self name:EDEventMouseDragged object:currentElement];
            [_nc removeObserver:self name:EDEventMouseUp object:currentElement];
        }
        i++;
    }
}

- (void)onGraphSelectedDeselectOtherGraphs:(NSNotification *)note{
    [_nc postNotificationName:EDEventUnselectedGraphClickedWithoutModifier object:self];
}

- (void)onElementMouseDown:(NSNotification *)note{
    // enables movement via multiple selection
    // notify all selectd subviews that mouse down was pressed
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (EDWorksheetElementView *myElement in [self subviews]){
        if([selectedElements containsObject:[myElement dataObj]]){
            // notify element that of mouse down
            [myElement mouseDownBySelection:[[note userInfo] valueForKey:EDEventKey]];
        }
    }
}

- (void)onElementMouseDragged:(NSNotification *)note{
    // enables movement via multiple selection
    // notify all selectd subviews that mouse down was pressed
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (EDWorksheetElementView *myElement in [self subviews]){
        if([selectedElements containsObject:[myElement dataObj]]){
            // notify element that of mouse dragged
            [myElement mouseDraggedBySelection:[[note userInfo] valueForKey:EDEventKey]];
        }
    }
}

- (void)onElementMouseUp:(NSNotification *)note{
    // enables movement via multiple selection
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
