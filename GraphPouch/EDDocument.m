//
//  EDDocument.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDDocument.h"
#import "EDWorksheetViewController.h"
#import "EDWorksheetScrollView.h"
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
- (void)onRootContextWillSave:(NSNotification *)note;
- (void)correctTokenAttributes;
- (void)onContextSaved:(NSNotification *)note;
- (void)onContextChanged:(NSNotification *)note;
@end

@implementation EDDocument

-(id)getInstance{
    return self;
}

- (id)init
{
    NSLog(@"init document");
    self = [super init];
    if (self) {
        // Create a parent context
        
        //Init code
        NSDictionary *contexts;
        contexts = [EDCoreDataUtility createContext:[self managedObjectContext]];
        
        // set context that the rest of the application will modify
        _context = [contexts objectForKey:EDKeyContextChild];
        _rootContext = [contexts objectForKey:EDKeyContextRoot];
        
        // set managed object context for this persistent document will write to
        [self setManagedObjectContext:[contexts objectForKey:EDKeyContextRoot]];
        
        propertyController = [[EDPanelPropertiesController alloc] init];
        menuController = [[EDMenuController alloc] init];
        
        // listen
        //[EDToken printAll:_context];
    }
    return self;
}

- (void)onRootContextWillSave:(NSNotification *)note{
    [self correctTokenAttributes];
}

- (void)correctTokenAttributes{
#warning i REALLY don't like this.  For some reason the parent context is not saving the token attributes.  IsValid and TokenValue are being set to nil.  Consequently the data is not being saved to the persisten store (the file).
    NSArray *correctTokens = [EDToken getAllObjects:_context];
    NSManagedObjectID *objID;
    EDToken *incorrectToken;
    for (EDToken *correctToken in correctTokens){
        // get object id
        objID = [correctToken objectID];
        
        // find object in root context
        incorrectToken = (EDToken *)[_rootContext objectRegisteredForID:objID];
        
        // copy attributes
        [incorrectToken copyToken:correctToken];
    }
    
}
- (void)onContextChanged:(NSNotification *)note{
    /*
    NSArray *updatedObjects = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    NSArray *insertedObjects = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    NSLog(@"context changed:\n===updated:%@ \n===inserted:%@", updatedObjects, insertedObjects);
     */
    // push changes to parent context
    //NSLog(@"before change: tokens root:%@ child root:%@", [EDToken getAllObjects:_rootContext], [EDToken getAllObjects:_context]);
    [EDCoreDataUtility save:_context];
    //NSLog(@"after change: tokens root:%@ child root:%@", [EDToken getAllObjects:_rootContext], [EDToken getAllObjects:_context]);
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
    [worksheetScrollView postInitialize];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShortcutSavePressed:) name:EDEventShortcutSave object:propertyController];
}

- (void)awakeFromNib{
    // code that happens before windowControllerDidLoadNib
    //NSLog(@"awake from nib");
    //[EDToken printAll:_context];
    //NSLog(@"end: awake from nib");
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextSaved:) name:NSManagedObjectContextDidSaveNotification object:_context];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRootContextWillSave:) name:NSManagedObjectContextWillSaveNotification object:_rootContext];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window{
    // have the undo manager linked to the managed object context
    return [_context undoManager];
}

- (void)togglePropertiesPanel:(id)sender{
    [propertyController togglePropertiesPanel:sender];
}

- (BOOL)propertiesPanelIsOpen{
    return [propertyController panelIsOpen];
}

#pragma mark page
- (IBAction)addPage:(id)sender{
    [pagesController addNewPage];
}

#pragma mark graph
- (IBAction)addGraph:(id)sender{
    [worksheetController addNewGraph];
}


#pragma mark window
- (void)onMainWindowClosed:(NSNotification *)note{
    // close auxilary panels
    [propertyController closePanel];
}

- (void)windowDidResize:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventWindowDidResize object:self];
    
    // notify scroll view that window resized
    [worksheetScrollView windowDidResize];
}

#pragma mark keyboard
- (void)onShortcutSavePressed:(NSNotification *)note{
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChildContextSaved:) name:NSManagedObjectContextWillSaveNotification object:_rootContext];
    [EDCoreDataUtility save:_context];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:_rootContext];
    
}

- (void)selectAll:(id)sender{
    [EDCoreDataUtility selectAllWorksheetElements:_context];
}

- (void)deselectAll:(id)sender{
    [EDCoreDataUtility clearSelectedWorksheetElements:_context];
}

#pragma mark model
/*
- (void)onChildContextSaved:(NSNotification *)note{
    // merge changes to root 
    [_rootContext mergeChangesFromContextDidSaveNotification:note];
}*/

@end
