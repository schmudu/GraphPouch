//
//  EDWorksheetView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDWorksheetView.h"
#import "EDGraphView.h"
#import "Graph.h"

@implementation EDWorksheetView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // init selected elements
        selectedElements = [[NSMutableDictionary alloc] init];
        
        // listen
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(onGraphSelected:) name:EDNotificationGraphSelectedWithShift object:nil];
        [nc addObserver:self selector:@selector(onGraphSelected:) name:EDNotificationGraphSelectedWithComand object:nil];
        [nc addObserver:self selector:@selector(onGraphSelected:) name:EDNotificationGraphSelected object:nil];
        [nc addObserver:self selector:@selector(onGraphDeselected:) name:EDNotificationGraphDeselected object:nil];
        [nc addObserver:self selector:@selector(handleNewGraphAdded:) name:EDNotificationGraphAdded object:nil];
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

#pragma mark mouse behavior
- (void)mouseDown:(NSEvent *)theEvent{
    //post notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:EDNotificationWorksheetClicked object:self];
}

#pragma mark Listeners
- (void)handleNewGraphAdded:(NSNotification *)note{
    // draw new graph view
    Graph *myGraph = [note object];
    EDGraphView *graph = [[EDGraphView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40) graphModel:myGraph];
    
    [self addSubview:graph];
    [self setNeedsDisplay:TRUE];
    
    /*
    // listen
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onGraphSelected:) name:EDNotificationGraphSelectedWithShift object:nil];
    [nc addObserver:self selector:@selector(onGraphSelected:) name:EDNotificationGraphSelectedWithComand object:nil];
    [nc addObserver:self selector:@selector(onGraphSelected:) name:EDNotificationGraphSelected object:nil];
    [nc addObserver:self selector:@selector(onGraphDeselected:) name:EDNotificationGraphDeselected object:nil];
     */
}

#pragma mark Graphs
- (void)onGraphSelected:(NSNotification *)note{
    NSLog(@"graph was selected.%@", [note object]);
    //add graph to selected elements
    EDGraphView *graph = (EDGraphView *)[note object];
    
    //add graph to selected elements
    [self addSelectedElement:graph forKey:[graph viewID]];
     
    //undo
    NSUndoManager *undo = [self undoManager];
    [[undo prepareWithInvocationTarget:self] removeSelectedElement:[graph viewID]];
    
    if (![undo isUndoing]) {
        [undo setActionName:@"Select Graph"];
    }
}


#pragma mark selection
- (void)onGraphDeselected:(NSNotification *)note{
    EDGraphView *graph = (EDGraphView *)[note object];
    
    //add graph to selected elements
    [self removeSelectedElement:[graph viewID]];
    
    //undo
    NSUndoManager *undo = [self undoManager];
    [[undo prepareWithInvocationTarget:self] addSelectedElement:graph forKey:[graph viewID]];
    
    if (![undo isUndoing]) {
        [undo setActionName:@"Deselect Graph"];
    }
}

- (void)addSelectedElement:(id)element forKey:(NSString *)id{
    [selectedElements setObject:element forKey:id];
    
    // post notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:EDNotificationWorksheetElementAdded object:self];
}

- (void)removeSelectedElement:(NSString *)id{
    [selectedElements removeObjectForKey:id];
    
    // post notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:EDNotificationWorksheetElementRemoved object:self];
}


- (BOOL)elementSelected:(id)element{
    //return whether or not the element exists with the selection dictionary
    id result = [selectedElements objectForKey:[element viewID]];
    NSLog(@"going to look for elem: count: %lu id:%@ result:%d", [selectedElements count], result, (result == nil));
    if (result == nil)
        return FALSE;
    else 
        return TRUE;
}
@end
