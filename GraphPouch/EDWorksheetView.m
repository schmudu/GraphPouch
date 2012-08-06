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
        // init selected elements
        selectedElements = [[NSMutableDictionary alloc] init];
 
        EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
        NSManagedObjectContext *context = [coreData context];
        
        // listen
        nc = [NSNotificationCenter defaultCenter];
        //[nc addObserver:self selector:@selector(onNewGraphAdded:) name:EDEventGraphAdded object:context];
        [nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
        /*
        [nc addObserver:self selector:@selector(onGraphClicked:) name:EDEventElementClickedWithShift object:context];
        [nc addObserver:self selector:@selector(onGraphClicked:) name:EDEventElementClickedWithCommand object:context];
        [nc addObserver:self selector:@selector(onGraphClicked:) name:EDEventElementClicked object:context];
        [nc addObserver:self selector:@selector(onWorksheetClicked:) name:EDEventWorksheetClicked object:context];
        [nc addObserver:self selector:@selector(onNewGraphAdded:) name:EDEventGraphAdded object:context];
         */
        //[nc addObserver:self selector:@selector(onWorksheetClicked:) name:EDEventWorksheetClicked object:self];
        //[nc addObserver:self selector:@selector(onNewGraphAdded:) name:NSManagedObjectContextDidSaveNotification object:context];
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [nc removeObserver:self name:EDEventElementClickedWithShift object:nil];
    [nc removeObserver:self name:EDEventElementClickedWithCommand object:nil];
    [nc removeObserver:self name:EDEventElementClicked object:nil];
}

- (void)loadDataFromManagedObjectContext{
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
#warning need to alter this to allow the drawing different types of elements
    //draw graphs
    //NSLog(@"load data from managed context: %@", [coreData context]);
    
    // load data
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Graph" inManagedObjectContext:[coreData context]];
    [request setEntity:entity];
    
    NSArray *results = [[coreData context] executeFetchRequest:request error:&error];    
    //NSLog(@"results: %ld", [results count]);
    for (Graph *elem in results){
        //draw graph
        [self drawGraph:elem];
    }
    //NSLog(@"edworksheetview load data from amanaged object context.");
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

- (void)drawGraph:(Graph *)graph{
    EDGraphView *graphView = [[EDGraphView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40) graphModel:graph];
    
    // set location
    [graphView setFrameOrigin:NSMakePoint([graph locationX], [graph locationY])];
    [self addSubview:graphView];
    [self setNeedsDisplay:TRUE];
    
    // add observer
    [nc addObserver:self selector:@selector(onGraphClicked:) name:EDEventElementClickedWithShift object:graphView];
    [nc addObserver:self selector:@selector(onGraphClicked:) name:EDEventElementClickedWithCommand object:graphView];
    [nc addObserver:self selector:@selector(onGraphClicked:) name:EDEventElementClicked object:graphView];
}

#pragma mark mouse behavior
- (void)mouseDown:(NSEvent *)theEvent{
    //post notification
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:EDEventWorksheetClicked object:self];
}

#pragma mark Listeners
- (void)onContextChanged:(NSNotification *)note{
    //Graph *myGraph = [note object];
    NSArray *insertedArray = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    NSArray *deletedArray = [[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects];
    //Graph *myGraph = [[note userInfo] objectForKey:@"inserted"];
    //NSLog(@"new graph added: %@ count:%ld", [[[note userInfo] objectForKey:NSInsertedObjectsKey] class], [insertedArray count]);
    //NSLog(@"new graph updated: %@ count:%ld", [[[note userInfo] objectForKey:NSUpdatedObjectsKey] class], [updatedArray count]);
    //NSLog(@"new graph deleted: %@ count:%ld", [[[note userInfo] objectForKey:NSDeletedObjectsKey] class], [deletedArray count]);
    // draw graphs that were added
    for (Graph *myGraph in insertedArray){
        //NSLog(@"insert graph: %@", myGraph);
        [self drawGraph:myGraph];
    }
    
    /*
    for (Graph *myGraph in updatedArray){
        NSLog(@"udpate graph: %@", myGraph);
        //[self drawGraph:myGraph];
    }*/
}

#pragma mark Graphs
#warning need to change this to allow for dragging
- (void)onGraphClicked:(NSNotification *)note{
    //NSLog(@"clicked on the graph.");
    EDGraphView *graph = (EDGraphView *)[note object];
    // if the user pressed 'command' or 'shift' add this graph to selection
    if(([note userInfo] != nil) && (([(NSString *)[[note userInfo] objectForKey:@"key"] isEqualToString:@"command"]) || ([(NSString *)[[note userInfo] objectForKey:@"key"] isEqualToString:@"shift"]))){
        //NSLog(@"need to simply add another element to the selection.");
        //add graph to selected elements
 
        if([self graphIsSelected:graph]){
            // remove graph was selected elements
            [self removeSelectedElement:[graph viewID]];
            
            //undo
            /*
            NSUndoManager *undo = [self undoManager];
            [[undo prepareWithInvocationTarget:self] addSelectedElement:graph forKey:[graph viewID]];
            
            if (![undo isUndoing]) {
                [undo setActionName:@"Deselect Graph"];
            }*/
        }
        else{
            // graph is not selected
            //add graph to selected elements
            [self addSelectedElement:graph forKey:[graph viewID]];
             
            //undo
            /*
            NSUndoManager *undo = [self undoManager];
            [[undo prepareWithInvocationTarget:self] removeSelectedElement:[graph viewID]];
            
            if (![undo isUndoing]) {
                [undo setActionName:@"Select Graph"];
            }*/
        }
    }
    else{
        // graph is not selected
        if(![self graphIsSelected:graph]){
            // add this object to the selected elements and deselect all other elements
            // save all object for undo
            NSMutableDictionary *undoElements = [[NSMutableDictionary alloc] init];
            for (NSString *key in selectedElements){
                //NSLog(@"key:%@ object:%@", key, [selectedElements objectForKey:key]);
                [undoElements setObject:[selectedElements objectForKey:key] forKey:key];
            }
            
            //clear out graphs from selected elements
            [selectedElements removeAllObjects];
            
            //add graph to selected elements
            EDGraphView *graph = (EDGraphView *)[note object];
            
            //add graph to selected elements
            [self addSelectedElement:graph forKey:[graph viewID]];
             
            //undo
            /*
            NSUndoManager *undo = [self undoManager];
            [[undo prepareWithInvocationTarget:self] removeSelectedElement:[graph viewID] andAddElements:undoElements];
            
            if (![undo isUndoing]) {
                [undo setActionName:@"Select Graph"];
            }*/
        }
    }
}


#pragma mark selection
- (BOOL)graphIsSelected:(EDGraphView *)graphView{
    if([selectedElements objectForKey:[graphView viewID]])
        return TRUE;
    else {
        return FALSE;
    }
        
}

- (void)onWorksheetClicked:(NSNotification *)note{
    // remove all the elements from the selected elements
    NSMutableArray *prevSelectedElements = [[NSMutableArray alloc] init];
    for (id key in selectedElements){
        [prevSelectedElements addObject:[selectedElements objectForKey:key]]; 
    }
    
    // remove all object from selected elements
    [selectedElements removeAllObjects];
    
    // undo
    /*
    NSUndoManager *undo = [self undoManager];
    [[undo prepareWithInvocationTarget:self] addSelectedElements:prevSelectedElements];
    
    if (![undo isUndoing]) {
        [undo setActionName:@"Deselect"];
    }*/
    
    // dispatch event
    [nc postNotificationName:EDEventWorksheetElementRemoved object:self];
}

- (void)addSelectedElements:(NSMutableArray *)elements{
    for (EDWorksheetElementView *element in elements){
        [self addSelectedElement:element forKey:[element viewID]];
    }
}
- (void)addSelectedElement:(id)element forKey:(NSString *)id{
    //NSLog(@"adding:%@", element);
    [selectedElements setObject:element forKey:id];
    
    // post notification
    [nc postNotificationName:EDEventWorksheetElementAdded object:self];
}

- (void)removeSelectedElement:(NSString *)id{
    [selectedElements removeObjectForKey:id];
    
    // post notification
    [nc postNotificationName:EDEventWorksheetElementRemoved object:self];
}


- (void)removeSelectedElement:(NSString *)id andAddElements:(NSMutableDictionary *)undoElements{
    // remove object
    [selectedElements removeObjectForKey:id];
    
    // add elements back to array
    [selectedElements addEntriesFromDictionary:undoElements];
     
    // post notification
    [nc postNotificationName:EDEventWorksheetElementRemoved object:self];
    
}

- (BOOL)elementSelected:(id)element{
    //return whether or not the element exists with the selection dictionary
    id result = [selectedElements objectForKey:[element viewID]];
    //NSLog(@"going to look for elem: count: %lu id:%@ result:%d", [selectedElements count], result, (result == nil));
    if (result == nil)
        return FALSE;
    else 
        return TRUE;
}
@end
