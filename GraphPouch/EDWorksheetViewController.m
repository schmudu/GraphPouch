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
@end

@implementation EDWorksheetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _nc = [NSNotificationCenter defaultCenter];
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        
        // listen
    }
    
    return self;
}

- (void)postInitialize{
    // listeners
    [_nc addObserver:self selector:@selector(deselectAllElements:) name:EDEventWorksheetClicked object:[self view]];
    [_nc addObserver:self selector:@selector(deselectAllElements:) name:EDEventUnselectedGraphClickedWithoutModifier object:[self view]];
    [_nc addObserver:self selector:@selector(deleteSelectedElements:) name:EDEventDeleteKeyPressedWithoutModifiers object:[self view]];
    [_nc addObserver:self selector:@selector(alignElementsToTop:) name:EDEventMenuAlignTop object:nil];
    
    // initialize view to display all of the worksheet elements
    [(EDWorksheetView *)[self view] drawLoadedObjects];
    
    // listen
    [_nc addObserver:self selector:@selector(onWindowResized:) name:EDEventWindowDidResize object:_documentController];
}

- (void)deselectAllElements:(NSNotification *)note{
    // clear all the selected elements
    [[EDCoreDataUtility sharedCoreDataUtility] clearSelectedWorksheetElements];
}

- (void)dealloc{
    [_nc removeObserver:self name:EDEventWorksheetClicked object:[self view]];
    [_nc removeObserver:self name:EDEventUnselectedGraphClickedWithoutModifier object:[self view]];
    [_nc removeObserver:self name:EDEventDeleteKeyPressedWithoutModifiers object:[self view]];
    [_nc removeObserver:self name:EDEventMenuAlignTop object:nil];
    [_nc removeObserver:self name:EDEventWindowDidResize object:_documentController];
}

- (void)deleteSelectedElements:(NSNotification *)note{
    [_coreData deleteSelectedWorksheetElements];
}

#pragma mark graphs
- (void)addNewGraph{
    // create new graph
    EDPage *currentPage = [_coreData getCurrentPage];
    
    EDGraph *newGraph = [[EDGraph alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:[_coreData context]] insertIntoManagedObjectContext:[_coreData context]];
    
    // add graph to page
    [currentPage addGraphsObject:newGraph];
    
    // set graph attributes
    [newGraph setPage:currentPage];
    [newGraph setHasGridLines:TRUE];
    [newGraph setHasTickMarks:TRUE];
    [newGraph setSelected:FALSE];
    [newGraph setLocationX:50];
    [newGraph setLocationY:150];
    [newGraph setElementWidth:70];
    [newGraph setElementHeight:70];
}

#pragma mark align
- (void)alignElementsToTop:(NSNotification *)note{
    NSLog(@"need to align elements to the top.");
}

#pragma mark window
- (void)onWindowResized:(NSNotification *)note{
    //NSLog(@"window was resized: width:%f height:%f", [[self view] frame].size.width, [[self view] frame].size.height);
}
@end
