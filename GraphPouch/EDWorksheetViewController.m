//
//  EDWorksheetControllerViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDWorksheetViewController.h"
#import "EDWorksheetView.h"
#import "EDConstants.h"
#import "EDGraph.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDPoint.h"

@interface EDWorksheetViewController ()
- (void)deselectAllElements:(NSNotification *)note;
- (void)deleteSelectedElements:(NSNotification *)note;
- (void)onWindowResized:(NSNotification *)note;
- (void)cutSelectedElements:(NSNotification *)note;
- (void)pasteElements:(NSNotification *)note;
@end

@implementation EDWorksheetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _nc = [NSNotificationCenter defaultCenter];
        
        // listen
    }
    
    return self;
}

- (void)postInitialize:(NSManagedObjectContext *)context{
    
    _context = context;
    
    // listeners
    [_nc addObserver:self selector:@selector(deselectAllElements:) name:EDEventWorksheetClicked object:[self view]];
    [_nc addObserver:self selector:@selector(deselectAllElements:) name:EDEventUnselectedGraphClickedWithoutModifier object:[self view]];
    [_nc addObserver:self selector:@selector(deleteSelectedElements:) name:EDEventDeleteKeyPressedWithoutModifiers object:[self view]];
    [_nc addObserver:self selector:@selector(alignElementsToTop:) name:EDEventMenuAlignTop object:nil];
    [_nc addObserver:self selector:@selector(cutSelectedElements:) name:EDEventShortcutCut object:[self view]];
    [_nc addObserver:self selector:@selector(pasteElements:) name:EDEventShortcutPaste object:[self view]];
    
    // initialize view to display all of the worksheet elements
    [(EDWorksheetView *)[self view] drawLoadedObjects];
    // listen
    [_nc addObserver:self selector:@selector(onWindowResized:) name:EDEventWindowDidResize object:_documentController];
}

- (void)deselectAllElements:(NSNotification *)note{
    // clear all the selected elements
    [EDCoreDataUtility clearSelectedWorksheetElements:_context];
}

- (void)dealloc{
    [_nc removeObserver:self name:EDEventWorksheetClicked object:[self view]];
    [_nc removeObserver:self name:EDEventUnselectedGraphClickedWithoutModifier object:[self view]];
    [_nc removeObserver:self name:EDEventDeleteKeyPressedWithoutModifiers object:[self view]];
    [_nc removeObserver:self name:EDEventMenuAlignTop object:nil];
    [_nc removeObserver:self name:EDEventWindowDidResize object:_documentController];
    [_nc removeObserver:self name:EDEventShortcutCut object:[self view]];
    [_nc removeObserver:self name:EDEventShortcutPaste object:[self view]];
}

- (void)deleteSelectedElements:(NSNotification *)note{
    [EDCoreDataUtility deleteSelectedWorksheetElements:_context];
}

#pragma mark graphs
- (void)addNewGraph{
    // create new graph
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    
    EDGraph *newGraph = [[EDGraph alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    
    // add graph to page
    [currentPage addGraphsObject:newGraph];
    
    // set graph attributes
    [newGraph setPage:currentPage];
    [newGraph setHasGridLines:TRUE];
    [newGraph setHasTickMarks:TRUE];
    [newGraph setSelected:FALSE];
    [newGraph setLocationX:50];
    [newGraph setLocationY:150];
    [newGraph setElementWidth:300];
    [newGraph setElementHeight:300];
}

#pragma mark align
- (void)alignElementsToTop:(NSNotification *)note{
    NSLog(@"need to align elements to the top.");
}

#pragma mark window
- (void)onWindowResized:(NSNotification *)note{
    //NSLog(@"window was resized: width:%f height:%f", [[self view] frame].size.width, [[self view] frame].size.height);
}

#pragma mark keyboard shortcuts
- (void)cutSelectedElements:(NSNotification *)note{
    // copy elements to pasteboard
    NSMutableArray *copiedElements = [EDCoreDataUtility copySelectedWorksheetElements:_context];
    
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:copiedElements];
    //NSLog(@"before: going to cut elements from core data: copied:%@", copiedElements);
    
    // delete elements from core data
    [EDCoreDataUtility deleteSelectedWorksheetElements:_context];
    //NSLog(@"after: going to cut elements from core data: copied:%@", copiedElements);
    
    // test
    /*
    NSArray *classes = [NSArray arrayWithObject:[EDGraph class]];
    
    NSArray *objects = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:nil];
    NSLog(@"after: pasteboard:%@", objects);
     */
}

- (void)pasteElements:(NSNotification *)note{
#warning add other elements here, need to add other classes
    NSArray *classes = [NSArray arrayWithObject:[EDGraph class]];
    
    NSArray *objects = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:nil];
    //NSLog(@"after: pasteboard:%@", objects);
    [EDCoreDataUtility insertWorksheetElements:objects context:_context];
}
@end
