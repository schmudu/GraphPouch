//
//  EDDocument.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//
#import "EDPage.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDDocument.h"
#import "EDWorksheetViewController.h"
#import "EDPagesViewController.h"
#import "EDGraph.h"
#import "EDToken.h"
#import "EDCoreDataUtility.h"
#import "EDCoreDataUtility+Worksheet.h"
#import "EDMenuController.h"
#import "EDPanelPropertiesController.h"
#import "NSObject+Document.h"
#import "EDConstants.h"
#import "EDWorksheetView.h"
#import "EDWindow.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDDocument()
- (void)onMainWindowClosed:(NSNotification *)note;
- (void)onShortcutSavePressed:(NSNotification *)note;
- (void)onPagesViewTabKeyPressed:(NSNotification *)note;
- (void)onWorksheetTabKeyPressed:(NSNotification *)note;
- (void)onContextSaved:(NSNotification *)note;
- (void)onContextChanged:(NSNotification *)note;
@end

@implementation EDDocument

-(id)getInstance{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Create a parent context
        
        //Init code
        NSDictionary *contexts;
        contexts = [EDCoreDataUtility createContext:[self managedObjectContext]];
        
        // set context that the rest of the application will modify
        _context = [contexts objectForKey:EDKeyContextChild];
        _rootContext = [contexts objectForKey:EDKeyContextRoot];
        NSLog(@"===root context:%@ child context:%@", _rootContext, _context);
        // set managed object context for this persistent document will write to
        [self setManagedObjectContext:[contexts objectForKey:EDKeyContextRoot]];
        
        propertyController = [[EDPanelPropertiesController alloc] init];
        
        // autoenable menu bar
        [[[[NSApp mainMenu] itemWithTitle:@"Edit"] submenu] setAutoenablesItems:TRUE];
        // listen
        //[EDToken printAll:_context];
    }
    return self;
}

- (void)onContextChanged:(NSNotification *)note{
    /*
    NSArray *updatedObjects = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    NSArray *insertedObjects = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    NSArray *deletedObjects = [[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects];
    NSLog(@"context changed:\n===updated:%@ \n===inserted:%@ \n===deleted:%@", updatedObjects, insertedObjects, deletedObjects);
     */
    
    // push changes to parent context
    //NSLog(@"\n\n===before change:\ntokens root:%@ \nchild root:%@", [EDToken getAllObjects:_rootContext], [EDToken getAllObjects:_context]);
    //NSLog(@"\n\n===before change:\ntokens root:%@ \nchild root:%@", [EDGraph getAllObjects:_rootContext], [EDGraph getAllObjects:_context]);
    [EDCoreDataUtility save:_context];
    //NSLog(@"\n\n===after change: \ntokens root:%@ \nchild root:%@", [EDToken getAllObjects:_rootContext], [EDToken getAllObjects:_context]);
    //NSLog(@"\n\n===after change: \ntokens root:%@ \nchild root:%@", [EDGraph getAllObjects:_rootContext], [EDGraph getAllObjects:_context]);
}

- (void)onContextSaved:(NSNotification *)note{
    //NSLog(@"===before save: tokens root:%@ child root:%@", [EDToken getAllObjects:_rootContext], [EDToken getAllObjects:_context]);
    [_rootContext mergeChangesFromContextDidSaveNotification:note];
    //NSLog(@"===after save: tokens root:%@ child root:%@", [EDToken getAllObjects:_rootContext], [EDToken getAllObjects:_context]);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[_context parentContext]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWindowWillClose object:[self windowForSheet]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventShortcutSave object:mainWindow];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventShortcutSave object:propertyController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:_rootContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventTabPressedWithoutModifiers object:worksheetView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventTabPressedWithoutModifiers object:pagesView];
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
    [worksheetController postInitialize:_context];
    [pagesController postInitialize:_context];
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
}

- (void)awakeFromNib{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextSaved:) name:NSManagedObjectContextDidSaveNotification object:_context];
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
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChildContextSaved:) name:NSManagedObjectContextWillSaveNotification object:_rootContext];
    [EDCoreDataUtility save:_context];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:_rootContext];
    
}

- (IBAction)paste:(id)sender{
    NSArray *classes = [EDPage allWorksheetClasses];
    NSArray *objects = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:nil];
    if ([objects count] > 0){
        [EDCoreDataUtility insertWorksheetElements:objects context:_context];
    }
    else {
        // paste in pages
        [pagesController pastePagesFromPasteboard];
    }
}

#pragma mark menu
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    //NSLog(@"key window:%d", ([NSApp keyWindow] == mainWindow));
    //NSLog(@"key window responder:%@ menu:%@", [mainWindow firstResponder], menuItem);
    // CRUD
    if ([[menuItem title] isEqualToString:@"Paste"]){
        //NSArray *classes = [NSArray arrayWithObjects:([EDGraph class], [EDPage class], nil)];
        NSArray *classes = [NSArray arrayWithObjects:[EDGraph class], [EDPage class], nil];
        
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
@end