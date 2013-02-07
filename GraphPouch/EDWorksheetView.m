//
//  EDWorksheetView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDCoreDataUtility+Worksheet.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDCoreDataUtility.h"
#import "EDDocument.h"
#import "EDGraph.h"
#import "EDGraphView.h"
#import "EDLine.h"
#import "EDLineView.h"
#import "EDPage.h"
#import "EDTextbox.h"
#import "EDTextboxView.h"
#import "EDTransformRect.h"
#import "EDTransformRectOnlyHorizontal.h"
#import "EDWorksheetView.h"
#import "EDWorksheetElementView.h"
#import "NSColor+Utilities.h"
#import "NSMutableDictionary+Utilities.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSObject+Worksheet.h"

@interface EDWorksheetView()
- (void)drawTextbox:(EDTextbox *)textbox;
- (void)drawGraph:(EDGraph *)graph;
- (void)drawLine:(EDLine *)line;
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
- (NSMutableDictionary *)getClosestVerticalGuide:(NSMutableArray *)guides point:(NSPoint)point;
- (NSMutableDictionary *)getClosestHorizontalGuide:(NSMutableArray *)guides point:(NSPoint)point;
- (float)findClosestPoint:(float)currentPoint guides:(NSMutableArray *)guides;

// elements
- (void)drawAllElements;
- (void)removeAllElements:(EDPage *)page;
- (void)removeElementView:(EDElement *)element;
- (NSMutableArray *)getAllSelectedWorksheetElementsViews;
- (NSMutableArray *)getAllUnselectedWorksheetElementsViews;

// transform
- (void)drawTransformRect:(EDElement *)element;
- (void)updateTransformRects:(NSArray *)updatedElements;
- (void)mouseDragTransformRect:(NSEvent *)event element:(EDWorksheetElementView *)element;
- (void)onTransformRectChanged:(NSNotification *)note;
//- (EDWorksheetElementView *)findElementViewViaTransformRect:(EDTransformRect *)rect element:(EDElement *)element;
- (void)onTransformPointMouseUp:(NSNotification *)note;
- (void)onTransformPointMouseDown:(NSNotification *)note;
- (void)removeTransformRect:(EDTransformRect *)transformRect element:(EDElement *)element;
@end

@implementation EDWorksheetView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mouseIsDown = FALSE;
        _elementIsBeingModified = FALSE;
        
        // these dictionaries are the reverse of each other
        _transformRects = [[NSMutableDictionary alloc] init];
        _elementsWithTransformRects = [[NSMutableDictionary alloc] init];
        
        /*
        // find current page
        EDPage *newPage = (EDPage *)[EDPage getCurrentPage];
        _currentPage = newPage;
        
        // listen
        _nc = [NSNotificationCenter defaultCenter];
        [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
         */
    }
    
    return self;
}

- (void)postInitialize:(NSManagedObjectContext *)context{
    //NSLog(@"worksheet frame: x:%f y:%f width:%f height:%f superview:%@", [self frame].origin.x, [self frame].origin.y, [self frame].size.width, [self frame].size.height, [(NSClipView *)[self superview] documentView]);
    _context = context;
    
    // find current page
    EDPage *newPage = (EDPage *)[EDPage getCurrentPage:context];
    _currentPage = newPage;
    
    // listen
    _nc = [NSNotificationCenter defaultCenter];
    [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
}

- (void)dealloc{
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

#pragma mark drawing
NSComparisonResult viewCompareBySelection(NSView *firstView, NSView *secondView, void *context) {
    // order view by isSelected
    EDWorksheetElementView *firstElement;
    EDWorksheetElementView *secondElement;
    
    if ([firstView isKindOfClass:[EDWorksheetElementView class]]) {
        firstElement = (EDWorksheetElementView *)firstView;
        if ([secondView isKindOfClass:[EDWorksheetElementView class]]) {
            secondElement = (EDWorksheetElementView *)secondView;
            // set ordering
            if ([[firstElement dataObj] selected] && (![[secondElement dataObj] selected])){
                return NSOrderedDescending;
            }
        }
    }
    return NSOrderedAscending;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawLoadedObjects{
    [self drawAllElements];
}

- (void)drawRect:(NSRect)dirtyRect{
    //NSLog(@"redrawing workseet: dirty rect: x:%f y%f w:%f h:%f", dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, dirtyRect.size.height);
    NSRect bounds = [self bounds];
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:bounds];
    
    // draw only the closest guides
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // only do if we're snapping and at least one element is selected
    if ((_mouseIsDown) && ([defaults boolForKey:EDPreferenceSnapToGuides])) {
        
        // either element is being modified or transform rect is
        if (_elementIsBeingModified) {
            // get all elements
            NSMutableArray *elements = [self getAllSelectedWorksheetElementsViews];
            NSMutableDictionary *closestVerticalGuide = [self getClosestVerticalGuide:[_guides objectForKey:EDKeyGuideVertical] elements:elements];
            NSMutableDictionary *closestHorizontalGuide = [self getClosestHorizontalGuide:[_guides objectForKey:EDKeyGuideHorizontal] elements:elements];
            
            // draw vertical guide
            if ([[closestVerticalGuide valueForKey:EDKeyGuideDiff] floatValue] < EDGuideShowThreshold) {
                [self drawGuide:NSMakePoint(0, [[closestVerticalGuide valueForKey:EDKeyClosestGuide] floatValue]) endPoint:NSMakePoint([self frame].size.width, [[closestVerticalGuide valueForKey:EDKeyClosestGuide] floatValue])];
            }
            
            // draw horizontal guide
            if ([[closestHorizontalGuide valueForKey:EDKeyGuideDiff] floatValue] < EDGuideShowThreshold) {
                [self drawGuide:NSMakePoint([[closestHorizontalGuide valueForKey:EDKeyClosestGuide] floatValue], 0) endPoint:NSMakePoint([[closestHorizontalGuide valueForKey:EDKeyClosestGuide] floatValue], [self frame].size.height)];
            }
        }
        else {
            // get all elements
            NSMutableDictionary *closestVerticalGuide = [self getClosestVerticalGuide:[_guides objectForKey:EDKeyGuideVertical] point:_transformRectDragPoint];
            NSMutableDictionary *closestHorizontalGuide = [self getClosestHorizontalGuide:[_guides objectForKey:EDKeyGuideHorizontal] point:_transformRectDragPoint];
            
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

- (void)drawTextbox:(EDTextbox *)textbox{
    EDTextboxView *textboxView = [[EDTextboxView alloc] initWithFrame:NSMakeRect(0, 0, [textbox elementWidth], [textbox elementHeight]) textboxModel:(EDTextbox *)textbox];
    
    // listen to graph
    // NOTE: any listeners you add here, remove them in method 'removeElementView'
    [_nc addObserver:self selector:@selector(onElementSelectedDeselectOtherElements:) name:EDEventUnselectedElementClickedWithoutModifier object:textboxView];
    [_nc addObserver:self selector:@selector(onElementMouseDown:) name:EDEventMouseDown object:textboxView];
    [_nc addObserver:self selector:@selector(onElementMouseDragged:) name:EDEventMouseDragged object:textboxView];
    [_nc addObserver:self selector:@selector(onElementMouseUp:) name:EDEventMouseUp object:textboxView];
    
    // set location
    [textboxView setFrameOrigin:NSMakePoint([[textbox valueForKey:EDElementAttributeLocationX] floatValue], [[textbox valueForKey:EDElementAttributeLocationY] floatValue])];
    
    [self addSubview:textboxView];
    [textboxView postInit];
    [textboxView setNeedsDisplay:TRUE];
    
    // draw transform rect if selected
    if ([[[textboxView dataObj] valueForKey:EDElementAttributeSelected] boolValue]){
        [self drawTransformRect:(EDElement *)[textboxView dataObj]];
    }
}

- (void)drawLine:(EDLine *)line{
    EDLineView *lineView = [[EDLineView alloc] initWithFrame:NSMakeRect(0, 0, [line elementWidth], [line elementHeight]) lineModel:(EDLine *)line];
    
    // listen to graph
    // NOTE: any listeners you add here, remove them in method 'removeElementView'
    [_nc addObserver:self selector:@selector(onElementSelectedDeselectOtherElements:) name:EDEventUnselectedElementClickedWithoutModifier object:lineView];
    [_nc addObserver:self selector:@selector(onElementMouseDown:) name:EDEventMouseDown object:lineView];
    [_nc addObserver:self selector:@selector(onElementMouseDragged:) name:EDEventMouseDragged object:lineView];
    [_nc addObserver:self selector:@selector(onElementMouseUp:) name:EDEventMouseUp object:lineView];
    
    // set location
    [lineView setFrameOrigin:NSMakePoint([[line valueForKey:EDElementAttributeLocationX] floatValue], [[line valueForKey:EDElementAttributeLocationY] floatValue])];
    
    [self addSubview:lineView];
    [lineView setNeedsDisplay:TRUE];
    
    // draw transform rect if selected
    if ([[[lineView dataObj] valueForKey:EDElementAttributeSelected] boolValue]){
        [self drawTransformRect:(EDElement *)[lineView dataObj]];
    }
}

- (void)drawGraph:(EDGraph *)graph{
    EDGraphView *graphView = [[EDGraphView alloc] initWithFrame:NSMakeRect(0, 0, [graph elementWidth], [graph elementHeight]) graphModel:(EDGraph *)graph];
    
    // listen to graph
    // NOTE: any listeners you add here, remove them in method 'removeElementView'
    [_nc addObserver:self selector:@selector(onElementSelectedDeselectOtherElements:) name:EDEventUnselectedElementClickedWithoutModifier object:graphView];
    [_nc addObserver:self selector:@selector(onElementMouseDown:) name:EDEventMouseDown object:graphView];
    [_nc addObserver:self selector:@selector(onElementMouseDragged:) name:EDEventMouseDragged object:graphView];
    [_nc addObserver:self selector:@selector(onElementMouseUp:) name:EDEventMouseUp object:graphView];
    
    // set location
    [graphView setFrameOrigin:NSMakePoint([[graph valueForKey:EDElementAttributeLocationX] floatValue], [[graph valueForKey:EDElementAttributeLocationY] floatValue])];
    
    // draw graph attributes
    [graphView drawElementAttributes];
    
    [self addSubview:graphView];
    [graphView setNeedsDisplay:TRUE];
    
    // draw transform rect if selected
    if ([[[graphView dataObj] valueForKey:EDElementAttributeSelected] boolValue]){
        [self drawTransformRect:(EDElement *)[graphView dataObj]];
    }
}

#pragma mark first responder
- (BOOL)becomeFirstResponder{
    [_nc postNotificationName:EDEventBecomeFirstResponder object:self];
    /*
     NSResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        NSLog(@"responder: %@", responder);
    }*/
    return YES;
}

- (BOOL)resignFirstResponder{
    [_nc postNotificationName:EDEventWorksheetViewResignFirstResponder object:self];
    return YES;
}

#pragma mark keyboard
- (void)keyDown:(NSEvent *)theEvent{
    NSUInteger flags = [theEvent modifierFlags];
    if(flags == EDKeyModifierNone && [theEvent keyCode] == EDKeycodeTab){
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventTabPressedWithoutModifiers object:self];
    }
    else if(flags == EDKeyModifierNone && [theEvent keyCode] == EDKeycodeDelete){
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventDeleteKeyPressedWithoutModifiers object:self];
    }
}



- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    // CRUD
    if ([[menuItem title] isEqualToString:@"Copy"]){
         EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
        NSArray *items = [page getAllSelectedWorksheetObjects];
        if ([items count] > 0)
            return TRUE;
        else
            return FALSE;
    }
    
    if ([[menuItem title] isEqualToString:@"Cut"]){
         EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
        NSArray *items = [page getAllSelectedWorksheetObjects];
        if ([items count] > 0)
            return TRUE;
        else
            return FALSE;
    }
    
    if ([[menuItem title] isEqualToString:@"Select All"]){
         EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
        NSArray *items = [page getAllWorksheetObjects];
        if ([items count] > 0)
            return TRUE;
        else
            return FALSE;
    }
    
    if ([[menuItem title] isEqualToString:@"Deselect All"]){
        EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
        NSArray *items = [page getAllWorksheetObjects];
        if ([items count] > 0)
            return TRUE;
        else
            return FALSE;
    }
    
    return [super validateMenuItem:menuItem];
}

- (IBAction)cut:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutCut object:self];
}

- (IBAction)copy:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutCopy object:self];
}

- (IBAction)selectAll:(id)sender{
    [EDCoreDataUtility selectAllWorksheetElementsOnCurrentPage:_context];
}

- (IBAction)deselectAll:(id)sender{
    [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context];
}

#pragma mark listeners
- (void)onContextChanged:(NSNotification *)note{
    EDPage *newPage = (EDPage *)[EDPage getCurrentPage:_context];
    if (newPage == _currentPage) {
        // only redraw the objects on page
        NSArray *insertedArray = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
        
        // insert elements
        for (EDElement *myElement in insertedArray){
            // draw graph if it's located on this page
            if (([[myElement className] isEqualToString:EDEntityNameGraph]) && (newPage == [(EDGraph *)myElement page])) {
                [self drawGraph:(EDGraph *)myElement];
            }
            
            // draw line if it's located on this page
            if (([[myElement className] isEqualToString:EDEntityNameLine]) && (newPage == [(EDLine *)myElement page])) {
                [self drawLine:(EDLine *)myElement];
            }
            
            // draw textbox
            if (([[myElement className] isEqualToString:EDEntityNameTextbox]) && (newPage == [(EDLine *)myElement page])) {
                [self drawTextbox:(EDTextbox *)myElement];
            }
#warning worksheet elements
        }
        
        // delete elements
        NSArray *deletedArray = [[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects];
        EDTransformRect *transformRect;
        for (EDElement *element in deletedArray){
            // remove worksheet element from worksheet only if it's a worksheet element
            if ([element isKindOfClass:[EDElement class]]){
                [self removeElementView:element];
            }
            
            // remove transform rects if exists
            transformRect = [_transformRects objectForKey:[NSValue valueWithNonretainedObject:element]];
            if(transformRect)
                [self removeTransformRect:transformRect element:element];
        }
        
        // update transform rects
        NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
        [self updateTransformRects:updatedArray];
    }
    else {
        // need to erase everything and redraw
        [self removeAllElements:_currentPage];
        
        // redraw
        [self drawAllElements];
        
        // set this page as the new current
        _currentPage = newPage;
    }
}

- (void)removeElementView:(EDElement *)element{
    BOOL found = FALSE;
    int i = 0;
    EDWorksheetElementView *currentElement;
    //for (EDGraphView *graphView in [self subviews]){
    while (!found && i<[[self subviews] count]){
        currentElement = (EDWorksheetElementView *)[[self subviews] objectAtIndex:i];
        if (([currentElement isKindOfClass:[EDWorksheetElementView class]]) && ([currentElement dataObj] == element)){
            found = TRUE;
            [currentElement removeFromSuperview];
        
            // remove listener
            [_nc removeObserver:self name:EDEventUnselectedElementClickedWithoutModifier object:currentElement];
            [_nc removeObserver:self name:EDEventMouseDown object:currentElement];
            [_nc removeObserver:self name:EDEventMouseDragged object:currentElement];
            [_nc removeObserver:self name:EDEventMouseUp object:currentElement];
        }
        i++;
    }
}

- (void)onElementSelectedDeselectOtherElements:(NSNotification *)note{
    [_nc postNotificationName:EDEventUnselectedElementClickedWithoutModifier object:self];
}

#pragma mark mouse behavior
- (void)mouseDown:(NSEvent *)theEvent{
    // make this the first responder
    [[self window] makeFirstResponder:self];
    
    //post notification
    [_nc postNotificationName:EDEventWorksheetClicked object:self];
}

- (void)onElementMouseDown:(NSNotification *)note{
    // order views
    [self sortSubviewsUsingFunction:&viewCompareBySelection context:nil];
    
    // enables movement via multiple selection
    // notify all selectd subviews that mouse down was pressed
    NSArray *selectedElements = [EDCoreDataUtility getAllSelectedWorksheetElements:_context];
    for (NSObject *myElement in [self subviews]){
        // remove heavy features while something is being dragged
        if ([myElement isWorksheetElement]){
            [(EDWorksheetElementView *)myElement removeFeatures];
        }
        
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
    _elementIsBeingModified = TRUE;   
}

- (void)onElementMouseDragged:(NSNotification *)note{
    // enables movement via multiple selection
    // notify all selectd subviews that mouse down was pressed
    NSArray *selectedElements = [EDCoreDataUtility getAllSelectedWorksheetElements:_context];
    for (NSObject *myElement in [self subviews]){
        // remove heavy features while something is being dragged
        if ([myElement isWorksheetElement]){
            [(EDWorksheetElementView *)myElement removeFeatures];
        }
        
        if(([myElement isWorksheetElement]) && ([selectedElements containsObject:[(EDWorksheetElementView *)myElement dataObj]])){
            // notify element that of mouse dragged
            // do not notify element if it was the original element that was dragged
            if (myElement != [[note userInfo] valueForKey:EDKeyWorksheetElement]) {
                [(EDWorksheetElementView *)myElement mouseDraggedBySelection:[[note userInfo] valueForKey:EDEventKey] snapInfo:[[note userInfo] valueForKey:EDKeySnapInfo]];
            }
            
            // notify transform rect if it has one
            [self mouseDragTransformRect:[[note userInfo] valueForKey:EDEventKey] element:(EDWorksheetElementView *)myElement];
        }
    }
    [self setNeedsDisplay:TRUE];
}

- (void)onElementMouseUp:(NSNotification *)note{
    // enables movement via multiple selection
    // notify all selectd subviews that mouse down was pressed
    NSArray *selectedElements = [EDCoreDataUtility getAllSelectedWorksheetElements:_context];
    for (NSObject *myElement in [self subviews]){
        // add heavy features on mouse up
        if ([myElement isWorksheetElement]){
            [(EDWorksheetElementView *)myElement addFeatures];
        }
        
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
    _elementIsBeingModified = FALSE;   
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
    float absoluteSmallestDiff = EDNumberMax;
    
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
        // origin is the origin of the element where as edge represents the far side
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

- (NSMutableDictionary *)getClosestHorizontalGuide:(NSMutableArray *)guides point:(NSPoint)point{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    float originDiff, originClosestGuide;
    
    // for each point find the closest point
    // find closest point to origin
    originClosestGuide = [self findClosestPoint:point.x guides:guides];
    originDiff = fabsf(point.x - originClosestGuide);
    
    [results setValue:[[NSNumber alloc] initWithFloat:originClosestGuide] forKey:EDKeyClosestGuide];
    [results setValue:[[NSNumber alloc] initWithFloat:originDiff] forKey:EDKeyGuideDiff];
    
    return results;
}

- (NSMutableDictionary *)getClosestVerticalGuide:(NSMutableArray *)guides point:(NSPoint)point{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    float originDiff, originClosestGuide;
    
    // for each point find the closest point
    // find closest point to origin
    originClosestGuide = [self findClosestPoint:point.y guides:guides];
    originDiff = fabsf(point.y - originClosestGuide);
    
    [results setValue:[[NSNumber alloc] initWithFloat:originClosestGuide] forKey:EDKeyClosestGuide];
    [results setValue:[[NSNumber alloc] initWithFloat:originDiff] forKey:EDKeyGuideDiff];
    
    return results;
}

- (float)findClosestPoint:(float)currentPoint guides:(NSMutableArray *)guides{
    // go through guides and find closest point
    float smallestDiff = 999999;
    float closestPoint = 0;
    
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
- (void)drawAllElements{
    // draw all elements for the current page
    EDPage *currentPage = (EDPage *)[EDPage getCurrentPage:_context];
    
    // draw all graphs
    for (EDGraph *graph in [currentPage graphs]){
        [self drawGraph:graph];
    }
    
    // draw all lines
    for (EDLine *line in [currentPage lines]){
        [self drawLine:line];
    }
    
    // draw textboxes
    for (EDTextbox *textbox in [currentPage textboxes]){
        [self drawTextbox:textbox];
    }
#warning worksheet elements
}

- (void)removeAllElements:(EDPage *)page{
    // iterate through all objects for page
    
    //NSSet *worksheetElements = [page graphs];
    NSArray *worksheetElements = [page getAllWorksheetObjects];
    
    // remove transform rects
    for (EDElement *element in worksheetElements){
        EDTransformRect *transformRect;
        transformRect = [_transformRects objectForKey:[NSValue valueWithNonretainedObject:element]];
        if (transformRect) {
            [self removeTransformRect:transformRect element:element];
        }
        
        [self removeElementView:element];
    }
}

- (NSMutableArray *)getAllSelectedWorksheetElementsViews{
    // get all the selected worksheet elements
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *selectedElements = [EDCoreDataUtility getAllSelectedWorksheetElements:_context];
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
    NSArray *selectedElements = [EDCoreDataUtility getAllSelectedWorksheetElements:_context];
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
    EDTransformRect *newTransformRect;
    
    // set transform rect based on type of element that we're drawing
    if (![element isKindOfClass:[EDLine class]])
        newTransformRect = [[EDTransformRect alloc] initWithFrame:[self bounds] element:element];
    else
        newTransformRect = [[EDTransformRectOnlyHorizontal alloc] initWithFrame:[self bounds] element:element];
    
    // add to dictionary
    [_transformRects setObject:newTransformRect forKey:[NSValue valueWithNonretainedObject:element]];
    [_elementsWithTransformRects setObject:element forKey:[NSValue valueWithNonretainedObject:newTransformRect]];
    
    // listen
    [_nc addObserver:self selector:@selector(onTransformRectChanged:) name:EDEventTransformRectChanged object:newTransformRect];
    [_nc addObserver:self selector:@selector(onTransformPointMouseUp:) name:EDEventTransformMouseUp object:newTransformRect];
    [_nc addObserver:self selector:@selector(onTransformPointMouseDown:) name:EDEventTransformMouseDown object:newTransformRect];
    
    // add to view
    [self addSubview:newTransformRect];
}

- (void)updateTransformRects:(NSArray *)updatedElements{
    // need to update transform rects
    EDTransformRect *transformRect;
    BOOL isSelected;
    // iterate through elements
    for (NSObject *myObject in updatedElements){
        // check - only update if objects are displayed on worksheet
        if (![myObject isKindOfClass:[EDElement class]])
            break;
    
        // cast
        EDElement *myElement = (EDElement *)myObject;
        
        transformRect = [_transformRects objectForKey:[NSValue valueWithNonretainedObject:myElement]];
        isSelected = [myElement selected];
        
        // if obj has a value and that element is not selected the remove the transform rect 
        if ((!isSelected) && (transformRect)) {
            [self removeTransformRect:transformRect element:myElement];
        }
        else if((isSelected) && (!transformRect)) {
            [self drawTransformRect:myElement];
        }
        else{
            // update transform rect
            if (transformRect){ 
                NSPoint transformOrigin = NSMakePoint([myElement locationX], [myElement locationY]);
                [transformRect setDimensionAndPositionElementViewOrigin:transformOrigin element:myElement];
            }
        }
    }
}
    
- (void)removeTransformRect:(EDTransformRect *)transformRect element:(EDElement *)element{
    [transformRect removeFromSuperview];
     
    // remove listener
    [_nc removeObserver:self name:EDEventTransformRectChanged object:transformRect];
    [_nc removeObserver:self name:EDEventTransformMouseUp object:transformRect];
    [_nc removeObserver:self name:EDEventTransformMouseDown object:transformRect];
    
    //reset
    [_transformRects removeObjectForKey:[NSValue valueWithNonretainedObject:element]];
    [_elementsWithTransformRects removeObjectForKey:[NSValue valueWithNonretainedObject:transformRect]];
}

- (void)mouseDragTransformRect:(NSEvent *)event element:(EDWorksheetElementView *)element{
    EDTransformRect *transformRect = [_transformRects objectForKey:[NSValue valueWithNonretainedObject:[element dataObj]]];
    if (transformRect) {
        [transformRect setDimensionAndPositionElementViewOrigin:[element frame].origin element:[element dataObj]];
    }
}

- (void)onTransformPointMouseDown:(NSNotification *)note{
    // only do if we're snapping
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:EDPreferenceSnapToGuides]) {
        [self saveGuides];
    }
}

- (void)onTransformPointMouseUp:(NSNotification *)note{
    EDElement *element = [_elementsWithTransformRects objectForKey:[NSValue valueWithNonretainedObject:[note object]]];
    
    // set attributes
    [element setLocationX:[[[note userInfo] valueForKey:EDKeyLocationX] floatValue]];
    [element setLocationY:[[[note userInfo] valueForKey:EDKeyLocationY] floatValue]];
    [element setElementWidth:[[[note userInfo] valueForKey:EDKeyWidth] floatValue]];
    [element setElementHeight:[[[note userInfo] valueForKey:EDKeyHeight] floatValue]];
    
    _mouseIsDown = FALSE;
}

- (void)onTransformRectChanged:(NSNotification *)note{
    // transform rect changed
    // change corresponding worksheet element view
    
    // find the element view
    EDWorksheetElementView *elementView = [self findElementViewViaTransformRect:[note object]];
    NSPoint origin = NSMakePoint([[[note userInfo] valueForKey:EDKeyLocationX] floatValue], [[[note userInfo] valueForKey:EDKeyLocationY] floatValue]);
    
    // change element view
    [elementView setFrameOrigin:origin];
    [elementView setFrameSize:NSMakeSize([[[note userInfo] valueForKey:EDKeyWidth] floatValue], [[[note userInfo] valueForKey:EDKeyHeight] floatValue])];
    
    // remove any performance heavy features while redrawing
    [elementView removeFeatures];
    
    // signal to board to redraw guides
    _mouseIsDown = TRUE;
    
    // set transform points so that drawRect can reference them
    _transformRectDragPoint = NSMakePoint([[[note userInfo] valueForKey:EDKeyTransformDragPointX] floatValue], [[[note userInfo] valueForKey:EDKeyTransformDragPointY] floatValue]);
    [self setNeedsDisplay:TRUE];
}

#pragma mark utilities
- (EDWorksheetElementView *)findElementViewViaTransformRect:(EDTransformRect *)rect{
    // first get the element data object
    EDElement *element = [_elementsWithTransformRects objectForKey:[NSValue valueWithNonretainedObject:rect]];
    
    // using the data object, find the element view
    for (EDWorksheetElementView *elementView in [self subviews]){
        if (([elementView isKindOfClass:[EDWorksheetElementView class]]) && ([elementView dataObj] == element))
            return elementView;
    }
    return nil;
}
@end