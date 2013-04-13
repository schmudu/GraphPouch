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
#import "EDExpression.h"
#import "EDGraph.h"
#import "EDLine.h"
#import "EDPoint.h"
#import "EDTextbox.h"
#import "EDWorksheetView.h"
#import "EDWorksheetViewController.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDWorksheetViewController ()
- (void)copyElements:(NSNotification *)note;
- (void)cutSelectedElements:(NSNotification *)note;
- (void)deselectAllElements:(NSNotification *)note;
- (void)deleteSelectedElements:(NSNotification *)note;
- (void)onCommandGraph:(NSNotification *)note;
- (void)onCommandLine:(NSNotification *)note;
- (void)onCommandTextbox:(NSNotification *)note;
- (void)onKeyPressedArrow:(NSNotification *)note;
- (void)onSelectedRectangleDragged:(NSNotification *)note;
- (void)onTextboxDidBeginEditing:(NSNotification *)note;
- (void)onTextboxDidEndEditing:(NSNotification *)note;
- (void)onTextboxDidChange:(NSNotification *)note;
- (void)onWindowResized:(NSNotification *)note;
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

- (void)postInitialize:(NSManagedObjectContext *)context copyContext:(NSManagedObjectContext *)copyContext{
    _context = context;
    _copyContext = copyContext;
    
    // listeners
    [_nc addObserver:self selector:@selector(deselectAllElements:) name:EDEventWorksheetClicked object:[self view]];
    [_nc addObserver:self selector:@selector(deselectAllElements:) name:EDEventUnselectedElementClickedWithoutModifier object:[self view]];
    [_nc addObserver:self selector:@selector(deleteSelectedElements:) name:EDEventDeleteKeyPressedWithoutModifiers object:[self view]];
    [_nc addObserver:self selector:@selector(alignElementsToTop:) name:EDEventMenuAlignTop object:nil];
    [_nc addObserver:self selector:@selector(cutSelectedElements:) name:EDEventShortcutCut object:[self view]];
    [_nc addObserver:self selector:@selector(copyElements:) name:EDEventShortcutCopy object:[self view]];
    [_nc addObserver:self selector:@selector(pasteElements:) name:EDEventShortcutPaste object:[self view]];
    [_nc addObserver:self selector:@selector(onTextboxDidBeginEditing:) name:EDEventTextboxBeginEditing object:[self view]];
    [_nc addObserver:self selector:@selector(onTextboxDidEndEditing:) name:EDEventTextboxEndEditing object:[self view]];
    [_nc addObserver:self selector:@selector(onTextboxDidChange:) name:EDEventTextboxDidChange object:[self view]];
    [_nc addObserver:self selector:@selector(onKeyPressedArrow:) name:EDEventArrowKeyPressed object:[self view]];
    [_nc addObserver:self selector:@selector(onSelectedRectangleDragged:) name:EDEventMouseDragged object:[self view]];
    [_nc addObserver:self selector:@selector(onCommandGraph:) name:EDEventCommandGraph object:[self view]];
    [_nc addObserver:self selector:@selector(onCommandLine:) name:EDEventCommandLine object:[self view]];
    [_nc addObserver:self selector:@selector(onCommandTextbox:) name:EDEventCommandTextbox object:[self view]];
    
    // initialize view to display all of the worksheet elements
    [(EDWorksheetView *)[self view] drawLoadedObjects];
    // listen
    [_nc addObserver:self selector:@selector(onWindowResized:) name:EDEventWindowDidResize object:_documentController];
}

- (void)deselectAllElements:(NSNotification *)note{
    if ([note userInfo]){
        // clear all the selected elements and select worksheet element
        [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context selectElement:(EDElement *)[[note userInfo] objectForKey:EDKeyWorksheetElement]];
    }
    else {
        // clear all the selected elements
        [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context];
    }
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
    [_nc removeObserver:self name:EDEventTextboxDidChange object:[self view]];
    [_nc removeObserver:self name:EDEventArrowKeyPressed object:[self view]];
    [_nc removeObserver:self name:EDEventMouseDragged object:[self view]];
    [_nc removeObserver:self name:EDEventCommandGraph object:[self view]];
    [_nc removeObserver:self name:EDEventCommandLine object:[self view]];
    [_nc removeObserver:self name:EDEventCommandTextbox object:[self view]];
}

- (void)deleteSelectedElements:(NSNotification *)note{
    [EDCoreDataUtility deleteSelectedWorksheetElements:_context];
}

#pragma mark expression
- (void)addNewExpression{
    // create new expression
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    
    EDExpression *newExpression = [[EDExpression alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameExpression inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    
    // add expression to page
    [currentPage addExpressionsObject:newExpression];
    
    // set expression attributes
    [newExpression setPage:currentPage];
    [newExpression setSelected:FALSE];
    [newExpression setLocationX:50];
    [newExpression setLocationY:150];
    [newExpression setElementWidth:EDWorksheetLineSelectionWidth];
    [newExpression setElementHeight:EDWorksheetLineSelectionHeight];
    
    // enter default text
    [newExpression setExpression:@"3x"];
    
    // select this graph and deselect everything else
    [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context selectElement:newExpression];
    
}

#pragma mark textbox
- (void)addNewTextbox{
    // create new textbox
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
    
    // enter default text
    NSFont *defaultFont;
    defaultFont = [NSFont fontWithName:@"Helvetica" size:EDFontDefaultSizeTextbox];
    NSMutableAttributedString *defaultString = [[NSMutableAttributedString alloc] initWithString:EDTextViewDefaultString];
    [defaultString addAttribute:NSFontAttributeName value:defaultFont range:NSMakeRange(0, [defaultString length])];
    [newTextbox setTextValue:defaultString];
    
    // select this graph and deselect everything else
    [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context selectElement:newTextbox];
}

#pragma mark line
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
    
    // select this graph and deselect everything else
    [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context selectElement:newLine];
    
    // save
    //[EDCoreDataUtility save:_context];
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
    
    // select this graph and deselect everything else
    [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context selectElement:newGraph];
}

- (void)addLabelName{
    // create new textbox
    EDPage *currentPage = [EDCoreDataUtility getPageWithNumber:1 context:_context];
    
    EDTextbox *newTextbox = [[EDTextbox alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameTextbox inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    
    // add name textbox
    [currentPage addTextboxesObject:newTextbox];
    
    // set graph attributes
    [newTextbox setPage:currentPage];
    [newTextbox setSelected:FALSE];
    [newTextbox setLocationX:350];
    [newTextbox setLocationY:23];
    [newTextbox setElementWidth:100];
    [newTextbox setElementHeight:30];
    [newTextbox setTextValue:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Name"]]];
    
    // add line
    EDLine *newLine = [[EDLine alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameLine inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    
    // add graph to page
    [currentPage addLinesObject:newLine];
    
    // set graph attributes
    [newLine setPage:currentPage];
    [newLine setSelected:FALSE];
    [newLine setLocationX:400];
    [newLine setLocationY:15];
    [newLine setElementWidth:200];
    [newLine setElementHeight:EDWorksheetLineSelectionHeight];
    [newLine setThickness:1.0];
    
    // save
    //[EDCoreDataUtility save:_context];
}

- (void)addLabelDate{
    // create new textbox
    EDPage *currentPage = [EDCoreDataUtility getPageWithNumber:1 context:_context];
    
    EDTextbox *newTextbox = [[EDTextbox alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameTextbox inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    
    // add name textbox
    [currentPage addTextboxesObject:newTextbox];
    
    // set graph attributes
    [newTextbox setPage:currentPage];
    [newTextbox setSelected:FALSE];
    [newTextbox setLocationX:355];
    [newTextbox setLocationY:58];
    [newTextbox setElementWidth:100];
    [newTextbox setElementHeight:30];
    [newTextbox setTextValue:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Date"]]];
    
    // add line
    EDLine *newLine = [[EDLine alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameLine inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    
    // add graph to page
    [currentPage addLinesObject:newLine];
    
    // set graph attributes
    [newLine setPage:currentPage];
    [newLine setSelected:FALSE];
    [newLine setLocationX:400];
    [newLine setLocationY:50];
    [newLine setElementWidth:200];
    [newLine setElementHeight:EDWorksheetLineSelectionHeight];
    [newLine setThickness:1.0];
    
    // save
    //[EDCoreDataUtility save:_context];
}

#pragma mark menu
- (void)onCommandGraph:(NSNotification *)note{
    [self addNewGraph];
}

- (void)onCommandLine:(NSNotification *)note{
    [self addNewLine];
}

- (void)onCommandTextbox:(NSNotification *)note{
    [self addNewTextbox];
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
    NSMutableArray *copiedElements = [EDCoreDataUtility copySelectedWorksheetElementsFromContext:_context toContext:_copyContext];
    
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:copiedElements];
    
    [EDCoreDataUtility deleteSelectedWorksheetElements:_context];
}

- (void)pasteElements:(NSNotification *)note{
    // send to first responder
    [[[[self view] window] firstResponder] doCommandBySelector:@selector(paste:)];
}

- (void)copyElements:(NSNotification *)note{
    // copy elements to pasteboard
    NSMutableArray *copiedElements = [EDCoreDataUtility copySelectedWorksheetElementsFromContext:_context toContext:_copyContext];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:copiedElements];
}

#pragma textbox
- (void)onTextboxDidBeginEditing:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventTextboxBeginEditing object:self userInfo:[note userInfo]];
}

- (void)onTextboxDidEndEditing:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventTextboxEndEditing object:self];
}

- (void)onTextboxDidChange:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventTextboxDidChange object:self];
}

- (void)onKeyPressedArrow:(NSNotification *)note{
    // move elements around the worksheet
    NSEvent *userEvent = [(NSDictionary *)[note userInfo] objectForKey:EDKeyEvent];
    BOOL multipyModifier = FALSE;
    NSUInteger flags = [userEvent modifierFlags];
    EDDirection direction;
    
    if(flags & NSShiftKeyMask){
        multipyModifier = TRUE;
    }
    
    if ([userEvent keyCode] == EDKeycodeArrowDown)
        direction = EDDirectionDown;
    else if ([userEvent keyCode] == EDKeycodeArrowLeft)
        direction = EDDirectionLeft;
    else if ([userEvent keyCode] == EDKeycodeArrowRight)
        direction = EDDirectionRight;
    else
        direction = EDDirectionUp;
    
    // move all selected elements
    [EDCoreDataUtility moveSelectedWorksheetElements:direction multiplyModifier:multipyModifier context:_context];
}

#pragma mark pages
- (void)onPagesWillBeRemoved:(NSArray *)pagesToDelete{
    [(EDWorksheetView *)[self view] onPagesWillBeDeleted:pagesToDelete];
}
#pragma mark selection rectangle
- (void)onSelectedRectangleDragged:(NSNotification *)note{
    // select worksheet elements that intersect with two points
    NSPoint downPoint = [[[note userInfo] valueForKey:EDKeyPointDown] pointValue];
    NSPoint dragPoint = [[[note userInfo] valueForKey:EDKeyPointDrag] pointValue];
    float xStart, yStart;
    
    if (downPoint.x < dragPoint.x)
        xStart = downPoint.x;
    else
        xStart = dragPoint.x;
    
    if (downPoint.y < dragPoint.y)
        yStart = downPoint.y;
    else
        yStart = dragPoint.y;
    
    NSRect selectionRect = NSMakeRect(xStart, yStart, fabsf(downPoint.x - dragPoint.x), fabsf(downPoint.y - dragPoint.y));
    [EDCoreDataUtility selectElementsInRect:selectionRect context:_context];
}
@end
