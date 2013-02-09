//
//  EDWorksheetControllerViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDCoreDataUtility+Worksheet.h"
#import "EDGraph.h"
#import "EDLine.h"
#import "EDPoint.h"
#import "EDTextbox.h"
#import "EDWorksheetView.h"
#import "EDWorksheetViewController.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDWorksheetViewController ()
- (void)deselectAllElements:(NSNotification *)note;
- (void)deleteSelectedElements:(NSNotification *)note;
- (void)onWindowResized:(NSNotification *)note;
- (void)cutSelectedElements:(NSNotification *)note;
- (void)pasteElements:(NSNotification *)note;
- (void)copyElements:(NSNotification *)note;
- (void)onTextboxDidBeginEditing:(NSNotification *)note;
- (void)onTextboxDidEndEditing:(NSNotification *)note;
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
    [_nc addObserver:self selector:@selector(deselectAllElements:) name:EDEventUnselectedElementClickedWithoutModifier object:[self view]];
    [_nc addObserver:self selector:@selector(deleteSelectedElements:) name:EDEventDeleteKeyPressedWithoutModifiers object:[self view]];
    [_nc addObserver:self selector:@selector(alignElementsToTop:) name:EDEventMenuAlignTop object:nil];
    [_nc addObserver:self selector:@selector(cutSelectedElements:) name:EDEventShortcutCut object:[self view]];
    [_nc addObserver:self selector:@selector(pasteElements:) name:EDEventShortcutPaste object:[self view]];
    [_nc addObserver:self selector:@selector(copyElements:) name:EDEventShortcutCopy object:[self view]];
    [_nc addObserver:self selector:@selector(onTextboxDidBeginEditing:) name:EDEventTextboxBeginEditing object:[self view]];
    [_nc addObserver:self selector:@selector(onTextboxDidEndEditing:) name:EDEventTextboxEndEditing object:[self view]];
    
    // initialize view to display all of the worksheet elements
    [(EDWorksheetView *)[self view] drawLoadedObjects];
    // listen
    [_nc addObserver:self selector:@selector(onWindowResized:) name:EDEventWindowDidResize object:_documentController];
}

- (void)deselectAllElements:(NSNotification *)note{
    // clear all the selected elements
    [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context];
}

- (void)dealloc{
    [_nc removeObserver:self name:EDEventWorksheetClicked object:[self view]];
    [_nc removeObserver:self name:EDEventUnselectedElementClickedWithoutModifier object:[self view]];
    [_nc removeObserver:self name:EDEventDeleteKeyPressedWithoutModifiers object:[self view]];
    [_nc removeObserver:self name:EDEventMenuAlignTop object:nil];
    [_nc removeObserver:self name:EDEventWindowDidResize object:_documentController];
    [_nc removeObserver:self name:EDEventShortcutCut object:[self view]];
    [_nc removeObserver:self name:EDEventShortcutPaste object:[self view]];
    [_nc removeObserver:self name:EDEventTextboxBeginEditing object:[self view]];
    [_nc removeObserver:self name:EDEventTextboxEndEditing object:[self view]];
}

- (void)deleteSelectedElements:(NSNotification *)note{
    [EDCoreDataUtility deleteSelectedWorksheetElements:_context];
}

#pragma mark line
- (void)addNewTextbox{
    // create new graph
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    
    EDTextbox *newTextbox = [[EDTextbox alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameTextbox inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    
    // add graph to page
    [currentPage addTextboxesObject:newTextbox];
    
    // set graph attributes
    [newTextbox setPage:currentPage];
    [newTextbox setSelected:FALSE];
    [newTextbox setLocationX:50];
    [newTextbox setLocationY:150];
    [newTextbox setElementWidth:EDWorksheetLineSelectionWidth];
    [newTextbox setElementHeight:EDWorksheetLineSelectionHeight];
}

- (void)addNewLine{
    // create new graph
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    
    EDLine *newLine = [[EDLine alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameLine inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    
    // add graph to page
    [currentPage addLinesObject:newLine];
    
    // set graph attributes
    [newLine setPage:currentPage];
    [newLine setSelected:FALSE];
    [newLine setLocationX:50];
    [newLine setLocationY:150];
    [newLine setElementWidth:EDWorksheetLineSelectionWidth];
    [newLine setElementHeight:EDWorksheetLineSelectionHeight];
    [newLine setThickness:1.0];
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
    [newGraph setElementWidth:500];
    [newGraph setElementHeight:500];
    [newGraph setScaleX:[NSNumber numberWithInt:2]];
    [newGraph setScaleY:[NSNumber numberWithInt:2]];
    [newGraph setLabelIntervalX:[NSNumber numberWithInt:1]];
    [newGraph setLabelIntervalY:[NSNumber numberWithInt:1]];
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
    
    [EDCoreDataUtility deleteSelectedWorksheetElements:_context];
}

- (void)copyElements:(NSNotification *)note{
    // copy elements to pasteboard
    NSMutableArray *copiedElements = [EDCoreDataUtility copySelectedWorksheetElements:_context];
    
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:copiedElements];
}

- (void)pasteElements:(NSNotification *)note{
    NSArray *classes = [EDPage allWorksheetClasses];
    NSArray *objects = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:nil];
    [EDCoreDataUtility insertWorksheetElements:objects context:_context];
}

#pragma textbox
- (void)onTextboxDidBeginEditing:(NSNotification *)note{
    [[NSApp currentDocument] onTextboxDidBeginEditing];
}

- (void)onTextboxDidEndEditing:(NSNotification *)note{
    [[NSApp currentDocument] onTextboxDidEndEditing];
}
@end
