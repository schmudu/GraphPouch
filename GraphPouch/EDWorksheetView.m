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
- (void)drawGuide:(NSPoint)startPoint endPoint:(NSPoint)endPoint;
- (void)onContextChanged:(NSNotification *)note;
- (void)onElementMouseDown:(NSNotification *)note;
- (void)onElementMouseDragged:(NSNotification *)note;
- (void)onElementMouseUp:(NSNotification *)note;

// guides
- (void)saveGuides;
- (void)removeGuides;
- (NSMutableDictionary *)getClosestVerticalGuide:(NSMutableArray *)guides elements:(NSArray *)elements;
- (float)findClosestPoint:(float)currentPoint guides:(NSMutableArray *)guides;

// elements
- (NSMutableArray *)getAllSelectedWorksheetElementsViews;
- (NSMutableArray *)getAllUnselectedWorksheetElementsViews;
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

#pragma mark drawing
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
    
#warning add other elements here
    // draw graphs
    for(EDGraphView *graph in [self subviews]){
        [graph setNeedsDisplay:TRUE];
    }
    
    // draw only the closest guides
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only do if we're snapping and at least one element is selected
    if ((_mouseIsDown) && ([defaults boolForKey:EDPreferenceSnapToGuides])) {
        // get all elements
        NSMutableArray *elements = [self getAllSelectedWorksheetElementsViews];
        NSMutableDictionary *closestGuide = [self getClosestVerticalGuide:[_guides objectForKey:EDKeyGuideVertical] elements:elements];
        if ([[closestGuide valueForKey:EDKeyGuideDiff] floatValue] < EDGuideShowThreshold) {
            [self drawGuide:NSMakePoint(0, [[closestGuide valueForKey:EDKeyClosestGuide] floatValue]) endPoint:NSMakePoint([self frame].size.width, [[closestGuide valueForKey:EDKeyClosestGuide] floatValue])];
        }
    }
}

- (void)drawGuide:(NSPoint)startPoint endPoint:(NSPoint)endPoint{
        NSBezierPath *aPath;
        aPath = [NSBezierPath bezierPath];
        [aPath setLineWidth:EDGuideWidth];
        CGFloat dashedLined[] = {10.0, 10.0};
        [aPath setLineDash:dashedLined count:2 phase:0];
        [[NSColor blueColor] setStroke];
        //[aPath moveToPoint:NSMakePoint(0, [verticalPoint floatValue])];
        //[aPath lineToPoint:NSMakePoint([self frame].size.width, [verticalPoint floatValue])];
        [aPath moveToPoint:startPoint];
        [aPath lineToPoint:endPoint];
        [aPath stroke];
}

- (void)drawGraph:(EDGraph *)graph{
    EDGraphView *graphView = [[EDGraphView alloc] initWithFrame:NSMakeRect(0, 0, [graph elementWidth], [graph elementHeight]) graphModel:(EDGraph *)graph];
    
    // listen to graph
    // NOTE: any listeners you add here, remove them in method 'removeElementView'
    [_nc addObserver:self selector:@selector(onGraphSelectedDeselectOtherGraphs:) name:EDEventUnselectedGraphClickedWithoutModifier object:graphView];
    [_nc addObserver:self selector:@selector(onElementMouseDown:) name:EDEventMouseDown object:graphView];
    [_nc addObserver:self selector:@selector(onElementMouseDragged:) name:EDEventMouseDragged object:graphView];
    [_nc addObserver:self selector:@selector(onElementMouseUp:) name:EDEventMouseUp object:graphView];
    [_nc addObserver:self selector:@selector(onElementSnapped:) name:EDEventElementSnapped object:graphView];
    
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

#pragma mark listeners
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
            [_nc removeObserver:self name:EDEventElementSnapped object:currentElement];
        }
        i++;
    }
}

- (void)onGraphSelectedDeselectOtherGraphs:(NSNotification *)note{
    [_nc postNotificationName:EDEventUnselectedGraphClickedWithoutModifier object:self];
}

#pragma mark mouse behavior
- (void)mouseDown:(NSEvent *)theEvent{
    //post notification
    [_nc postNotificationName:EDEventWorksheetClicked object:self];
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
    
    // store all guides 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only do if we're snapping
    if ([defaults boolForKey:EDPreferenceSnapToGuides]) {
        [self saveGuides];
    }
    
    _mouseIsDown = TRUE;   
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
    
    [self setNeedsDisplay:TRUE];
}

- (void)onElementSnapped:(NSNotification *)note{
    // notify all selectd subviews that they need to snap too
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (EDWorksheetElementView *myElement in [self subviews]){
        if([selectedElements containsObject:[myElement dataObj]]){
            // notify element that of mouse dragged
            [myElement snapToPoint:[[[note userInfo] valueForKey:EDKeySnapOffset] floatValue]];
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
    
    // remove all guides 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only do if we're snapping
    if ([defaults boolForKey:EDPreferenceSnapToGuides]) {
        [self removeGuides];
    }
    
    _mouseIsDown = FALSE;   
    [self setNeedsDisplay:TRUE];
}

#pragma mark guides
- (NSMutableDictionary *)guides{
    return _guides;
}

- (void)saveGuides{
    // get the margin guides and all unselected elemnts
    _guides = [[NSMutableDictionary alloc] init];
    
    // add to guides any points that we can snap to
    NSMutableArray *guidesVertical = [[NSMutableArray alloc] init];
    NSMutableArray *guidesHorizontal = [[NSMutableArray alloc] init];
    
    // get all the unselected elements
    NSMutableArray *unselectedElements = [self getAllUnselectedWorksheetElementsViews];
    
    // iterate through unselected elements and store both edges of the element as a guide
    NSNumber *topGuide, *rightGuide, *bottomGuide, *leftGuide;
    for (EDWorksheetElementView *elementView in unselectedElements){
        topGuide = [[NSNumber alloc] initWithFloat:[elementView frame].origin.y];
        leftGuide = [[NSNumber alloc] initWithFloat:[elementView frame].origin.x];
        rightGuide = [[NSNumber alloc] initWithFloat:([elementView frame].origin.x + [[elementView dataObj] elementWidth])];
        bottomGuide = [[NSNumber alloc] initWithFloat:([elementView frame].origin.y + [[elementView dataObj] elementHeight])];
        
        // add guides
        [guidesVertical addObject:topGuide];
        [guidesVertical addObject:bottomGuide];
        [guidesHorizontal addObject:leftGuide];
        [guidesHorizontal addObject:rightGuide];
    }
    
    // set guides
    [_guides setValue:guidesVertical forKey:EDKeyGuideVertical];
    [_guides setValue:guidesHorizontal forKey:EDKeyGuideHorizontal];
}

- (void)removeGuides{
    _guides = nil;
}
                                             
- (NSMutableDictionary *)getClosestVerticalGuide:(NSMutableArray *)guides elements:(NSArray *)elements{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    float originDiff, edgeDiff, originClosestGuide, edgeClosestGuide, absoluteClosestGuide;
    float absoluteSmallestDiff = 999999;
    
    // for each point find the closest point
    for (EDWorksheetElementView *element in elements){
        // find closest point to origin
        originClosestGuide = [self findClosestPoint:[element frame].origin.y guides:guides];
        edgeClosestGuide = [self findClosestPoint:([element frame].origin.y + [[element dataObj] elementHeight]) guides:guides];
        originDiff = fabsf([element frame].origin.y - originClosestGuide);
        edgeDiff = fabsf(([element frame].origin.y + [[element dataObj] elementHeight])- edgeClosestGuide);
        if((edgeDiff >= originDiff) && (originDiff < absoluteSmallestDiff)){
            absoluteSmallestDiff = originDiff;
            absoluteClosestGuide = originClosestGuide;
        }
        else if((originDiff >= edgeDiff) && (edgeDiff < absoluteSmallestDiff)){
            absoluteSmallestDiff = edgeDiff;
            absoluteClosestGuide = edgeClosestGuide;
        }
    }
    [results setValue:[[NSNumber alloc] initWithFloat:absoluteClosestGuide] forKey:EDKeyClosestGuide];
    [results setValue:[[NSNumber alloc] initWithFloat:absoluteSmallestDiff] forKey:EDKeyGuideDiff];
    
    return results;
}

- (float)findClosestPoint:(float)currentPoint guides:(NSMutableArray *)guides{
    // go through guides and find closest point
    float smallestDiff = 999999;
    float closestPoint;
    
    // iterate through all the
    for (NSNumber *point in guides){
        if (fabsf(currentPoint - [point floatValue]) < smallestDiff) {
            // found smallest point so far
            smallestDiff = fabsf(currentPoint - [point floatValue]);
            closestPoint = [point floatValue];
        }
    }
    return closestPoint;
}

#pragma mark elements
- (NSMutableArray *)getAllSelectedWorksheetElementsViews{
    // get all the selected worksheet elements
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (EDWorksheetElementView *myElement in [self subviews]){
        if([selectedElements containsObject:[myElement dataObj]]){
            [results addObject:myElement];
        }
    }
    
    return results;
}

- (NSMutableArray *)getAllUnselectedWorksheetElementsViews{
    // get all the selected worksheet elements
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (EDWorksheetElementView *myElement in [self subviews]){
        if(![selectedElements containsObject:[myElement dataObj]]){
            [results addObject:myElement];
        }
    }
    
    return results;
}

@end