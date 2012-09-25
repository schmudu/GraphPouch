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
#import "EDWorksheetElementView.h"
#import "EDTransformRect.h"
#import "NSObject+Worksheet.h"

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
- (NSMutableDictionary *)getClosestHorizontalGuide:(NSMutableArray *)guides elements:(NSArray *)elements;
- (float)findClosestPoint:(float)currentPoint guides:(NSMutableArray *)guides;

// elements
- (NSMutableArray *)getAllSelectedWorksheetElementsViews;
- (NSMutableArray *)getAllUnselectedWorksheetElementsViews;

// transform
- (void)drawTransformRect:(EDElement *)element;
- (void)updateTransformRects:(NSArray *)updatedElements;
- (void)mouseDragTransformRect:(NSEvent *)event element:(EDWorksheetElementView *)element;
- (void)onTransformRectChanged:(NSNotification *)note;
@end

@implementation EDWorksheetView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        _context = [_coreData context];
        
        // these dictionaries are the reverse of each other
        _transformRects = [[NSMutableDictionary alloc] init];
        //_elementsWithTransformRects = [[NSMutableDictionary alloc] init];
        
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
    // draw only the closest guides
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only do if we're snapping and at least one element is selected
    if ((_mouseIsDown) && ([defaults boolForKey:EDPreferenceSnapToGuides])) {
        // get all elements
        NSMutableArray *elements = [self getAllSelectedWorksheetElementsViews];
        NSMutableDictionary *closestVerticalGuide = [self getClosestVerticalGuide:[_guides objectForKey:EDKeyGuideVertical] elements:elements];
        NSMutableDictionary *closestHorizontalGuide = [self getClosestHorizontalGuide:[_guides objectForKey:EDKeyGuideHorizontal] elements:elements];
        //NSLog(@"closest horiz guide:%f", [[closestHorizontalGuide valueForKey:EDKeyClosestGuide] floatValue]);
        // draw vertical guide
        if ([[closestVerticalGuide valueForKey:EDKeyGuideDiff] floatValue] < EDGuideShowThreshold) {
            [self drawGuide:NSMakePoint(0, [[closestVerticalGuide valueForKey:EDKeyClosestGuide] floatValue]) endPoint:NSMakePoint([self frame].size.width, [[closestVerticalGuide valueForKey:EDKeyClosestGuide] floatValue])];
        }
        
        // draw horizontal guide
        if ([[closestHorizontalGuide valueForKey:EDKeyGuideDiff] floatValue] < EDGuideShowThreshold) {
            [self drawGuide:NSMakePoint([[closestHorizontalGuide valueForKey:EDKeyClosestGuide] floatValue], 0) endPoint:NSMakePoint([[closestHorizontalGuide valueForKey:EDKeyClosestGuide] floatValue], [self frame].size.height)];
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
    
    // set location
    [graphView setFrameOrigin:NSMakePoint([[graph valueForKey:EDElementAttributeLocationX] floatValue], [[graph valueForKey:EDElementAttributeLocationY] floatValue])];
    [self addSubview:graphView];
    [graphView setNeedsDisplay:TRUE];
    
    // draw transform rect if selected
    if ([[graphView dataObj] selected]){
        [self drawTransformRect:(EDElement *)[graphView dataObj]];
    }
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
    
    // update transform rects
    NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    [self updateTransformRects:updatedArray];
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

#pragma mark mouse behavior
- (void)mouseDown:(NSEvent *)theEvent{
    //post notification
    [_nc postNotificationName:EDEventWorksheetClicked object:self];
}

- (void)onElementMouseDown:(NSNotification *)note{
    // enables movement via multiple selection
    // notify all selectd subviews that mouse down was pressed
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (NSObject *myElement in [self subviews]){
        if(([myElement isWorksheetElement]) && ([selectedElements containsObject:[(EDWorksheetElementView *)myElement dataObj]])){
            // notify element that of mouse down
            [(EDWorksheetElementView *)myElement mouseDownBySelection:[[note userInfo] valueForKey:EDEventKey]];
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
    for (NSObject *myElement in [self subviews]){
        //if(([myElement isWorksheetElement]) && (![selectedElements containsObject:[(EDWorksheetElementView *)myElement dataObj]])){
        if(([myElement isWorksheetElement]) && ([selectedElements containsObject:[(EDWorksheetElementView *)myElement dataObj]])){
            // notify element that of mouse dragged
            [(EDWorksheetElementView *)myElement mouseDraggedBySelection:[[note userInfo] valueForKey:EDEventKey]];
            
            // notify transform rect if it has one
            [self mouseDragTransformRect:[[note userInfo] valueForKey:EDEventKey] element:(EDWorksheetElementView *)myElement];
        }
    }
    [self setNeedsDisplay:TRUE];
}

- (void)onElementMouseUp:(NSNotification *)note{
    // enables movement via multiple selection
    // notify all selectd subviews that mouse down was pressed
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (NSObject *myElement in [self subviews]){
        if(([myElement isWorksheetElement]) && ([selectedElements containsObject:[(EDWorksheetElementView *)myElement dataObj]])){
            // notify element that of mouse dragged
            [(EDWorksheetElementView *)myElement mouseUpBySelection:[[note userInfo] valueForKey:EDEventKey]];
        }
    }
    
    // remove all guides 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only do if we're snapping
    if ([defaults boolForKey:EDPreferenceSnapToGuides]) {
        [self removeGuides];
    }
    
    [self setNeedsDisplay:TRUE];
    _mouseIsDown = FALSE;   
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
 
#warning add margin guides here
    // set guides
    [_guides setValue:guidesVertical forKey:EDKeyGuideVertical];
    [_guides setValue:guidesHorizontal forKey:EDKeyGuideHorizontal];
}

- (void)removeGuides{
    _guides = nil;
}
                                             
- (NSMutableDictionary *)getClosestHorizontalGuide:(NSMutableArray *)guides elements:(NSArray *)elements{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    float originDiff, edgeDiff, originClosestGuide, edgeClosestGuide, absoluteClosestGuide;
    float absoluteSmallestDiff = 999999;
    
    // for each point find the closest point
    for (EDWorksheetElementView *element in elements){
        // find closest point to origin
        originClosestGuide = [self findClosestPoint:[element frame].origin.x guides:guides];
        edgeClosestGuide = [self findClosestPoint:([element frame].origin.x + [[element dataObj] elementWidth]) guides:guides];
        originDiff = fabsf([element frame].origin.x - originClosestGuide);
        edgeDiff = fabsf(([element frame].origin.x + [[element dataObj] elementWidth])- edgeClosestGuide);
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
    for (NSObject *myElement in [self subviews]){
        // only add if it's a worksheet element
        if(([myElement isWorksheetElement]) && ([selectedElements containsObject:[(EDWorksheetElementView *)myElement dataObj]])){
            [results addObject:myElement];
        }
    }
    
    return results;
}

- (NSMutableArray *)getAllUnselectedWorksheetElementsViews{
    // get all the selected worksheet elements
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *selectedElements = [_coreData getAllSelectedObjects];
    for (NSObject *myElement in [self subviews]){
        if(([myElement isWorksheetElement]) && (![selectedElements containsObject:[(EDWorksheetElementView *)myElement dataObj]])){
            [results addObject:myElement];
        }
    }
    
    return results;
}

#pragma mark transform rect
- (void)drawTransformRect:(EDElement *)element{
    // create new transform rect
    EDTransformRect *newTransformRect = [[EDTransformRect alloc] initWithFrame:NSMakeRect([element locationX], [element locationY], [element elementWidth], [element elementHeight])];
    
    // add to dictionary
    [_transformRects setObject:newTransformRect forKey:[NSValue valueWithNonretainedObject:element]];
    //[_elementsWithTransformRects setObject:elementView forKey:[NSValue valueWithNonretainedObject:newTransformRect]];
    
    // listen
    [_nc addObserver:self selector:@selector(onTransformRectChanged:) name:EDEventTransformRectChanged object:newTransformRect];
     
    // add to view
    [self addSubview:newTransformRect];
}

- (void)updateTransformRects:(NSArray *)updatedElements{
    // need to update transform rects
    EDTransformRect *transformRect;
    BOOL isSelected;
    // iterate through elements
    for (EDElement *myElement in updatedElements){
        transformRect = [_transformRects objectForKey:[NSValue valueWithNonretainedObject:myElement]];
        isSelected = [myElement selected];
        
        // if obj has a value and that element is not selected the remove the transform rect 
        if ((!isSelected) && (transformRect)) {
            [transformRect removeFromSuperview];
            
            // remove listener
            [_nc removeObserver:self name:EDEventTransformRectChanged object:transformRect];
            
            //reset
            [_transformRects removeObjectForKey:[NSValue valueWithNonretainedObject:myElement]];
            //[_elementsWithTransformRects removeObjectForKey:[NSValue valueWithNonretainedObject:transformRect]];
            
        }
        else if((isSelected) && (!transformRect)) {
            [self drawTransformRect:myElement];
        }
    }
}
    
- (void)mouseDragTransformRect:(NSEvent *)event element:(EDWorksheetElementView *)element{
    EDTransformRect *transformRect = [_transformRects objectForKey:[NSValue valueWithNonretainedObject:[element dataObj]]];
    if (transformRect) {
        [transformRect setFrameOrigin:[element frame].origin];
    }
}

- (void)onTransformRectChanged:(NSNotification *)note{
    // transform rect changed
    // change corresponding worksheet element view
    
    //EDWorksheetElementView *elementView = [_elementsWithTransformRects objectForKey:[NSValue valueWithNonretainedObject:[note object]]];
    NSPoint origin = NSMakePoint([[[note userInfo] valueForKey:EDKeyLocationX] floatValue], [[[note userInfo] valueForKey:EDKeyLocationY] floatValue]);
    
    //change element view
    //[elementView setFrameOrigin:origin];
    //[elementView setFrameSize:NSMakeSize([[[note userInfo] valueForKey:EDKeyWidth] floatValue], [[[note userInfo] valueForKey:EDKeyHeight] floatValue])];
}
@end