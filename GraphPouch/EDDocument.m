//
//  EDDocument.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDDocument.h"
#import "EDWorksheetViewController.h"
#import "EDPagesViewController.h"
#import "EDGraph.h"
#import "EDCoreDataUtility.h"
#import "EDMenuController.h"
#import "EDPanelPropertiesController.h"
#import "NSObject+Document.h"
#import "EDConstants.h"
#import "EDWorksheetView.h"
#import "EDWindow.h"

@interface EDDocument()
- (void)onMainWindowClosed:(NSNotification *)note;
- (void)onShortcutSavePressed:(NSNotification *)note;
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
        //_context = [self managedObjectContext];
        NSDictionary *contexts;
        contexts = [EDCoreDataUtility createContext:[self managedObjectContext]];
        
        // set context that the rest of the application will modify
        _context = [contexts objectForKey:EDKeyContextChild];
        
        // set managed object context for this persistent document will write to
        [self setManagedObjectContext:[contexts objectForKey:EDKeyContextRoot]];
        
        propertyController = [[EDPanelPropertiesController alloc] init];
        menuController = [[EDMenuController alloc] init];
        
        // listen
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[_context parentContext]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventWindowWillClose object:[self windowForSheet]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventShortcutSave object:mainWindow];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventShortcutSave object:propertyController];
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
    
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMainWindowClosed:) name:EDEventWindowWillClose object:[self windowForSheet]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShortcutSavePressed:) name:EDEventShortcutSave object:mainWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShortcutSavePressed:) name:EDEventShortcutSave object:propertyController];
}

- (void)awakeFromNib{
    // code that happens before windowControllerDidLoadNib
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
}

#pragma mark keyboard
- (void)onShortcutSavePressed:(NSNotification *)note{
    [EDCoreDataUtility save:_context];
}
@end
