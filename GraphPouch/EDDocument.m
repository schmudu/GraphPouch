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
#import "EDWindowControllerAbout.h"
#import "EDWorksheetView.h"
#import "EDWorksheetViewController.h"
#import "NSObject+Document.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDDocument()
- (void)onContextChanged:(NSNotification *)note;
- (void)onMainWindowClosed:(NSNotification *)note;
- (void)onPagesViewTabKeyPressed:(NSNotification *)note;
- (void)onPagesWillBeRemoved:(NSNotification *)note;
- (void)onPanelDocumentPressedDate:(NSNotification *)note;
- (void)onPanelDocumentPressedName:(NSNotification *)note;
- (void)onResetElementsZIndices:(NSNotification *)note;
- (void)onShortcutSavePressed:(NSNotification *)note;
- (void)onWorksheetTextboxDidBeginEditing:(NSNotification *)note;
- (void)onWorksheetTextboxDidEndEditing:(NSNotification *)note;
- (void)onWorksheetTextboxDidChange:(NSNotification *)note;
- (void)onWindowSettingTitle:(NSNotification *)note;
- (void)onWorksheetTabKeyPressed:(NSNotification *)note;
- (void)updatePageNumberInWindowTitle;
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
        
        NSPersistentStoreCoordinator *copyCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        [copyCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
        [_copyContext setPersistentStoreCoordinator:copyCoordinator];
        
        NSLog(@"===root context:%@ child context:%@ copy:%@ persistent stores:%@", _rootContext, _context, _copyContext, [[_rootContext persistentStoreCoordinator] persistentStores]);
        
        propertyController = [[EDPanelPropertiesController alloc] initWithWindowNibName:@"EDPanelProperties"];
        aboutController = [[EDWindowControllerAbout alloc] initWithWindowNibName:@"EDWindowAbout"];
        
        // autoenable menu bar
        [[[[NSApp mainMenu] itemWithTitle:@"Edit"] submenu] setAutoenablesItems:TRUE];
    }
    return self;
}

- (void)onContextChanged:(NSNotification *)note{
    // update title page number
    [self updatePageNumberInWindowTitle];
    
    // update counter that we have changes to be saved
    [self updateChangeCount:NSChangeUndone];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[_context parentContext]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWindowWillClose object:[self windowForSheet]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventShortcutSave object:mainWindow];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventShortcutSave object:propertyController];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPanelDocumentPressedName object:propertyController];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPanelDocumentPressedDate object:propertyController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:_rootContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventTabPressedWithoutModifiers object:worksheetView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventTabPressedWithoutModifiers object:pagesView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventTextboxBeginEditing object:worksheetController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWindowSettingTitle object:mainWindow];
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
    
    // set app delegate
    appController = [[EDAppController alloc] init];
    [NSApp setDelegate:appController];
    
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorksheetTextboxDidBeginEditing:) name:EDEventTextboxBeginEditing object:worksheetController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPagesWillBeRemoved:) name:EDEventPagesWillBeRemoved object:pagesController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWindowSettingTitle:) name:EDEventWindowSettingTitle object:mainWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResetElementsZIndices:) name:EDEventResetZIndices object:appController];
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
- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo{
    [worksheetController resetElementsZIndices];
    [super canCloseDocumentWithDelegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
}
- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL *)url ofType:(NSString *)fileType modelConfiguration:(NSString *)configuration storeOptions:(NSDictionary *)storeOptions error:(NSError **)error
{
    NSMutableDictionary *newStoreOptions;
    if (storeOptions == nil) {
        newStoreOptions = [NSMutableDictionary dictionary];
    }
    else {
        newStoreOptions = [storeOptions mutableCopy];
    }
    [newStoreOptions setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [newStoreOptions setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    
    BOOL result = [super configurePersistentStoreCoordinatorForURL:url ofType:fileType modelConfiguration:configuration storeOptions:newStoreOptions error:error];
    return result;
}

- (void)autosaveDocumentWithDelegate:(id)delegate didAutosaveSelector:(SEL)didAutosaveSelector contextInfo:(void *)contextInfo{
    [self updateChangeCount:NSChangeDone];
    [EDCoreDataUtility saveContext:_context];
    [super autosaveDocumentWithDelegate:delegate didAutosaveSelector:didAutosaveSelector contextInfo:contextInfo];
}

- (void)saveDocument:(id)sender{
    [self updateChangeCount:NSChangeDone];
    [EDCoreDataUtility saveContext:_context];
    [super saveDocument:sender];
    
    // maintain page number
    [self updatePageNumberInWindowTitle];
}

- (IBAction)togglePropertiesPanel:(id)sender{
    [propertyController togglePropertiesPanel:sender];
}

- (BOOL)propertiesPanelIsOpen{
    return [propertyController panelIsOpen];
}

#pragma mark expression
- (IBAction)expressionAdd:(id)sender{
    [worksheetController addNewExpression];
}

#pragma mark image
- (IBAction)imageAdd:(id)sender{
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // title
    [openDlg setTitle:@"Select Image to Insert"];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowsMultipleSelection:FALSE];
    
    // set file types
    //NSArray *fileTypes = [NSArray arrayWithObjects:@"bmp", @"BMP", @"jpeg", @"JPEG", @"jpg", @"JPG", @"png", @"PNG", @"tif", @"TIF", @"tiff", @"TIFF", nil];
    //[openDlg setAllowedFileTypes:fileTypes];
    [openDlg setAllowedFileTypes:[NSImage imageFileTypes]];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSFileHandlingPanelOKButton){
        NSURL* fileURL = [openDlg URL];
        [worksheetController addNewImage:fileURL];
    }
}

#pragma mark page
- (void)onPagesWillBeRemoved:(NSNotification *)note{
    [worksheetController onPagesWillBeRemoved:[[note userInfo] objectForKey:EDKeyPagesToRemove]];
}

- (IBAction)pageAdd:(id)sender{
    [pagesController addNewPage];
}

- (IBAction)pageNext:(id)sender{
    [EDCoreDataUtility gotoPageNext:_context];
}

- (IBAction)pagePrevious:(id)sender{
    [EDCoreDataUtility gotoPagePrevious:_context];
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
- (void)onWindowSettingTitle:(NSNotification *)note{
    // this only called upon initial loading of file
    [self updatePageNumberInWindowTitle];
}

- (void)onMainWindowClosed:(NSNotification *)note{
    // close auxilary panels
    [propertyController closePanel];
}

- (void)windowDidResize:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventWindowDidResize object:self];
    
    // notify scroll view that window resized
    [mainWorksheetView windowDidResize];
}

- (void)updatePageNumberInWindowTitle{
    // set title
    NSArray *pages = [EDPage getAllObjects:_context];
    EDPage *page = [EDCoreDataUtility getCurrentPage:_context];
    NSString *filename, *fileNameAndPath = [mainWindow representedFilename];
    
    // break into components
    NSArray *stringComponents = [fileNameAndPath componentsSeparatedByString:@"/"];
    
    // set to untitled if no name
    if ([fileNameAndPath isEqualToString:@""])
        filename = @"Untitled";
    else if ([stringComponents count] > 0){
        // get last component and set filename
        filename = (NSString *)[stringComponents lastObject];
    }
    
    [mainWindow setTitle:[NSString stringWithFormat:@"%@ (page %d of %ld)", filename, [[page pageNumber] intValue], [pages count]]];
}

#pragma mark keyboard
- (void)onWorksheetTabKeyPressed:(NSNotification *)note{
    [mainWindow makeFirstResponder:pagesView];
}

- (void)onPagesViewTabKeyPressed:(NSNotification *)note{
    [mainWindow makeFirstResponder:worksheetView];
}

- (void)onShortcutSavePressed:(NSNotification *)note{
    [EDCoreDataUtility saveContext:_context];
}

- (IBAction)paste:(id)sender{
    NSArray *graphPouchClasses = [EDPage allWorksheetClasses];
    NSArray *newModelObjects = [[NSPasteboard generalPasteboard] readObjectsForClasses:graphPouchClasses options:nil];
    NSArray *pageClasses = [NSArray arrayWithObject:[EDPage class]];
    NSArray *pageObjects = [[NSPasteboard generalPasteboard] readObjectsForClasses:pageClasses options:nil];
    NSArray *imageClasses = [NSArray arrayWithObjects:[NSImage class], nil];
    NSArray *imageObjects = [[NSPasteboard generalPasteboard] readObjectsForClasses:imageClasses options:nil];
    
    if ([newModelObjects count] > 0){
        // deselect all previously selected elements
        [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context];
        
        EDPage *currentPage = (EDPage *)[EDPage getCurrentPage:_context];
        NSArray *oldObjects = [EDCoreDataUtility getAllWorksheetElementsOnPage:currentPage context:_context];
        
        // retrieve new objects
        NSArray *newElements = [EDCoreDataUtility insertWorksheetElements:newModelObjects intoContext:_context];
        
        // if there are elements at the exact the same position then offset these elements so the user can see them
        // try matching just one object
        EDElement *newObject = (EDElement *)[newModelObjects objectAtIndex:0];
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
    else if([pageObjects count]>0){
        // paste in pages
        [pagesController pastePagesFromPasteboard];
    }
    else if([imageObjects count]>0){
        // for each image object, create EDImage entity
        [worksheetController insertImages:imageObjects];
    }
}

#pragma mark properties panel
- (void)propertiesPanelDisable:(id)sender{
    [propertyController panelObservingContextDisable];
}

- (void)propertiesPanelEnable:(id)sender{
    [propertyController panelObservingContextEnable];
}

#pragma mark menu
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    // CRUD
    if ([[menuItem title] isEqualToString:@"Paste"]){
        
        NSMutableArray *classes = [NSMutableArray arrayWithArray:[EDPage allWorksheetClasses]];
        [classes addObject:[EDPage class]];
        [classes addObject:[NSImage class]];
        
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
- (void)onWorksheetTextboxDidBeginEditing:(NSNotification *)note{
    [propertyController onTextboxDidBeginEditing:(EDTextView *)[[note userInfo] objectForKey:EDKeyTextView] currentTextbox:(EDTextbox *)[[note userInfo] objectForKey:EDKeyTextbox]];
}

- (void)onWorksheetTextboxDidEndEditing:(NSNotification *)note{
    [propertyController onTextboxDidEndEditing];
}

- (void)onWorksheetTextboxDidChange:(NSNotification *)note{
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

#pragma mark z-index
- (void)onResetElementsZIndices:(NSNotification *)note{
    [worksheetController resetElementsZIndices];
}
@end