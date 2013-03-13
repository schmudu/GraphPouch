//
//  EDDocument.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//
// testing
#import "EDLine.h"

#import "EDConstants.h"
#import "EDCoreDataUtility.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDCoreDataUtility+Worksheet.h"
#import "EDDocument.h"
#import "EDGraph.h"
#import "EDPage.h"
#import "EDPagesViewController.h"
#import "EDPanelPropertiesController.h"
#import "EDPrintView.h"
#import "EDToken.h"
//#import "EDWindow.h"
#import "EDWindowControllerAbout.h"
#import "EDWorksheetView.h"
#import "EDWorksheetViewController.h"
#import "NSObject+Document.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDDocument()
- (void)onMainWindowClosed:(NSNotification *)note;
- (void)onShortcutSavePressed:(NSNotification *)note;
- (void)onPagesViewTabKeyPressed:(NSNotification *)note;
- (void)onPanelDocumentPressedDate:(NSNotification *)note;
- (void)onPanelDocumentPressedName:(NSNotification *)note;
- (void)onWorksheetTabKeyPressed:(NSNotification *)note;
- (void)onContextChanged:(NSNotification *)note;
- (void)onTextboxDidBeginEditing:(NSNotification *)note;
- (void)onTextboxDidEndEditing:(NSNotification *)note;
- (void)onTextboxDidChange:(NSNotification *)note;
@end

@implementation EDDocument

-(id)getInstance{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Autosave
        [[NSDocumentController sharedDocumentController] setAutosavingDelay:EDAutosaveTimeIncrement];
        
        //Init code
        NSDictionary *contexts;
        contexts = [EDCoreDataUtility createContext:[self managedObjectContext]];
        
        // set context that the rest of the application will modify
        _context = [contexts objectForKey:EDKeyContextChild];
        _rootContext = [contexts objectForKey:EDKeyContextRoot];
        
        // set managed object context for this persistent document will write to
        [self setManagedObjectContext:[contexts objectForKey:EDKeyContextRoot]];
        
        // create copy context
        _copyContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        //[_copyContext setPersistentStoreCoordinator:[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]]];
        
        NSPersistentStoreCoordinator *copyCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        //[copyCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:[self managedObjectModel] URL:nil options:nil error:&error];
        [copyCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
        [_copyContext setPersistentStoreCoordinator:copyCoordinator];
        
        //NSLog(@"managed object model:%@", [self managedObjectModel]);
        
        NSLog(@"===root context:%@ child context:%@ copy:%@", _rootContext, _context, _copyContext);
        
        propertyController = [[EDPanelPropertiesController alloc] initWithWindowNibName:@"EDPanelProperties"];
        aboutController = [[EDWindowControllerAbout alloc] initWithWindowNibName:@"EDWindowAbout"];
        
        // autoenable menu bar
        [[[[NSApp mainMenu] itemWithTitle:@"Edit"] submenu] setAutoenablesItems:TRUE];
        // listen
        //[EDToken printAll:_context];
    }
    return self;
}

- (void)onContextChanged:(NSNotification *)note{
    // update counter that we have changes to be saved
    [self updateChangeCount:NSChangeUndone];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[_context parentContext]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWindowWillClose object:[self windowForSheet]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventShortcutSave object:mainWindow];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventShortcutSave object:propertyController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPanelDocumentPressedName object:propertyController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPanelDocumentPressedDate object:propertyController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:_rootContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventTabPressedWithoutModifiers object:worksheetView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventTabPressedWithoutModifiers object:pagesView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventTextboxBeginEditing object:worksheetController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventTextboxEndEditing object:worksheetController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventTextboxDidChange object:worksheetController];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"EDDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    [(EDWorksheetView *)worksheetView postInitialize:_context];
    [worksheetController setView:worksheetView];
    [worksheetController postInitialize:_context copyContext:_copyContext];
    [pagesController postInitialize:_context copyContext:_copyContext];
    [mainWindow postInitialize:_context];
    // post init property panel
    [propertyController postInitialize:_context];
    
    // disable undo for the initiation process
    [_context processPendingChanges];
    [[_context undoManager] removeAllActions];
    
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMainWindowClosed:) name:EDEventWindowWillClose object:[self windowForSheet]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShortcutSavePressed:) name:EDEventShortcutSave object:mainWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorksheetTabKeyPressed:) name:EDEventTabPressedWithoutModifiers object:worksheetView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPagesViewTabKeyPressed:) name:EDEventTabPressedWithoutModifiers object:pagesView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShortcutSavePressed:) name:EDEventShortcutSave object:propertyController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPanelDocumentPressedName:) name:EDEventPanelDocumentPressedName object:propertyController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPanelDocumentPressedDate:) name:EDEventPanelDocumentPressedDate object:propertyController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextboxDidBeginEditing:) name:EDEventTextboxBeginEditing object:worksheetController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextboxDidEndEditing:) name:EDEventTextboxEndEditing object:worksheetController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextboxDidChange:) name:EDEventTextboxDidChange object:worksheetController];
}

- (void)awakeFromNib{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window{
    // have the undo manager linked to the managed object context
    return [_context undoManager];
}

#pragma mark document
- (void)autosaveDocumentWithDelegate:(id)delegate didAutosaveSelector:(SEL)didAutosaveSelector contextInfo:(void *)contextInfo{
    [self updateChangeCount:NSChangeDone];
    //NSLog(@"===autosaving. location:%@", [[[NSDocumentController sharedDocumentController] currentDocument] autosavedContentsFileURL]);
    [EDCoreDataUtility validateElements:_context];
    [EDCoreDataUtility saveRootContext:_rootContext childContext:_context];
    [super autosaveDocumentWithDelegate:delegate didAutosaveSelector:didAutosaveSelector contextInfo:contextInfo];
}

- (void)saveDocument:(id)sender{
    [self updateChangeCount:NSChangeDone];
    [EDCoreDataUtility validateElements:_context];
    [EDCoreDataUtility saveRootContext:_rootContext childContext:_context];
    [super saveDocument:sender];
}

- (IBAction)togglePropertiesPanel:(id)sender{
    [propertyController togglePropertiesPanel:sender];
}

- (BOOL)propertiesPanelIsOpen{
    return [propertyController panelIsOpen];
}

#pragma mark page
- (IBAction)pageAdd:(id)sender{
    [pagesController addNewPage];
}

- (IBAction)pageNext:(id)sender{
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    EDPage *nextPage = [EDCoreDataUtility getPageWithNumber:([[currentPage pageNumber] intValue]+1) context:_context];
    
    if (nextPage)
        [EDCoreDataUtility setPageAsCurrent:nextPage context:_context];
    else
        [EDCoreDataUtility setPageAsCurrent:[EDCoreDataUtility getFirstPage:_context] context:_context];
}

- (IBAction)pagePrevious:(id)sender{
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    EDPage *nextPage = [EDCoreDataUtility getPageWithNumber:([[currentPage pageNumber] intValue]-1) context:_context];
    
    if (nextPage)
        [EDCoreDataUtility setPageAsCurrent:nextPage context:_context];
    else
        [EDCoreDataUtility setPageAsCurrent:[EDCoreDataUtility getLastPage:_context] context:_context];
}


#pragma mark line
- (IBAction)lineAdd:(id)sender{
    [worksheetController addNewLine];
}

#pragma mark graph
- (IBAction)graphAdd:(id)sender{
    [worksheetController addNewGraph];
}

#pragma mark textbox
- (IBAction)textboxAdd:(id)sender{
    [worksheetController addNewTextbox];
}

#pragma mark worksheet
- (IBAction)worksheetItemNext:(id)sender{
    [EDCoreDataUtility selectNextWorksheetElementOnCurrentPage:_context];
}

- (IBAction)worksheetItemPrevious:(id)sender{
    [EDCoreDataUtility selectPreviousWorksheetElementOnCurrentPage:_context];
}

#pragma mark window
- (void)onMainWindowClosed:(NSNotification *)note{
    // close auxilary panels
    [propertyController closePanel];
}

- (void)windowDidResize:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventWindowDidResize object:self];
    
    // notify scroll view that window resized
    [mainWorksheetView windowDidResize];
}

#pragma mark keyboard
- (void)onWorksheetTabKeyPressed:(NSNotification *)note{
    [mainWindow makeFirstResponder:pagesView];
}

- (void)onPagesViewTabKeyPressed:(NSNotification *)note{
    [mainWindow makeFirstResponder:worksheetView];
}

- (void)onShortcutSavePressed:(NSNotification *)note{
    [EDCoreDataUtility saveRootContext:_rootContext childContext:_context];
}

- (IBAction)paste:(id)sender{
    NSArray *classes = [EDPage allWorksheetClasses];
    NSArray *newObjects = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:nil];
    if ([newObjects count] > 0){
        // deselect all previously selected elements
        [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context];
        
        EDPage *currentPage = (EDPage *)[EDPage getCurrentPage:_context];
        NSArray *oldObjects = [EDCoreDataUtility getAllWorksheetElementsOnPage:currentPage context:_context];
        
        // retrieve new objects
        NSArray *newElements = [EDCoreDataUtility insertWorksheetElements:newObjects intoContext:_context];
        
        // if there are elements at the exact the same position then offset these elements so the user can see them
        // try matching just one object
        EDElement *newObject = (EDElement *)[newObjects objectAtIndex:0];
        EDElement *testObject;
        int counter = 0;
        BOOL samePositionMatch = FALSE;
        while ((!samePositionMatch) && (counter < [oldObjects count])){
            testObject = [oldObjects objectAtIndex:counter];
            
            // if object has same position then we have a match
            if (([testObject locationX] == [newObject locationX]) && ([testObject locationY] == [newObject locationY])){
                samePositionMatch = TRUE;
            }
            counter++;
        }
        
        // if match then offset the new objects, so it doesn't cover the old ones
        if (samePositionMatch){
            for (EDElement *element in newElements){
                // update to new position
                [element setValue:[NSNumber numberWithFloat:([element locationX] + EDCopyLocationOffset)] forKey:EDElementAttributeLocationX];
                [element setValue:[NSNumber numberWithFloat:([element locationY] + EDCopyLocationOffset)] forKey:EDElementAttributeLocationY];
            }
        }
    }
    else {
        // paste in pages
        [pagesController pastePagesFromPasteboard];
    }
}

#pragma mark menu
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    // CRUD
    if ([[menuItem title] isEqualToString:@"Paste"]){
        
        NSArray *pageClasses = [EDPage allWorksheetClasses];
        NSMutableArray *classes = [NSMutableArray arrayWithArray:pageClasses];
        [classes addObject:[EDPage class]];
        
        NSArray *objects = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:nil];
        
        // if there are page or any types of worksheet elements then allow paste
        if ([objects count] == 0)
            return FALSE;
        else
            return TRUE;
    }
    
    // pages
    if ([[menuItem title] isEqualToString:@"Next Page"]){
        NSArray *pages = [EDPage getAllObjects:_context];
        if ([pages count] <= 1)
            return FALSE;
    }
    
    if ([[menuItem title] isEqualToString:@"Previous Page"]){
        NSArray *pages = [EDPage getAllObjects:_context];
        if ([pages count] <= 1)
            return FALSE;
    }
    
    // worksheet
    if ([[menuItem title] isEqualToString:@"Next Worksheet Item"]){
        EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
        NSArray *items = [page getAllWorksheetObjects];
        if ([items count] == 0)
            return FALSE;
    }
    
    if ([[menuItem title] isEqualToString:@"Previous Worksheet Item"]){
        EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
        NSArray *items = [page getAllWorksheetObjects];
        if ([items count] == 0)
            return FALSE;
    }
    return [super validateMenuItem:menuItem];
}

#pragma mark textbox
- (void)onTextboxDidBeginEditing:(NSNotification *)note{
    //NSLog(@"text box beging editing:%@", [note userInfo]);
    [propertyController onTextboxDidBeginEditing:(EDTextView *)[[note userInfo] objectForKey:EDKeyTextView] currentTextbox:(EDTextbox *)[[note userInfo] objectForKey:EDKeyTextbox]];
}

- (void)onTextboxDidEndEditing:(NSNotification *)note{
    [propertyController onTextboxDidEndEditing];
}

- (void)onTextboxDidChange:(NSNotification *)note{
    [propertyController onTextboxDidChange];
}

#pragma mark printing
- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError *__autoreleasing *)outError{
    NSArray *pages = [EDPage getAllObjects:_context];
    EDPrintView *printView = [[EDPrintView alloc] initWithFrame:NSMakeRect(0, 0, EDWorksheetViewWidth, EDWorksheetViewHeight * [pages count]) context:_context];
    //EDPrintView *printView = [[EDPrintView alloc] initWithFrame:NSMakeRect(0, 0, EDWorksheetViewWidth, EDWorksheetViewHeight) context:_context];
    NSPrintInfo *printInfo = [self printInfo];
    NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:printView printInfo:printInfo];
    return printOp;
}

#pragma mark worksheet
- (void)onPanelDocumentPressedDate:(NSNotification *)note{
    [worksheetController addLabelDate];
}

- (void)onPanelDocumentPressedName:(NSNotification *)note{
    [worksheetController addLabelName];
}

#pragma mark about
- (IBAction)toggleAboutWindow:(id)sender{
    [aboutController toggleAboutWindow:sender];
}
@end