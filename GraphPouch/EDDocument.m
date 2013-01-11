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

@interface EDDocument()
- (void)onMainWindowClosed:(NSNotification *)note;
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
        _context = [EDCoreDataUtility createContext:[self managedObjectContext]];
        propertyController = [[EDPanelPropertiesController alloc] init];
        menuController = [[EDMenuController alloc] init];
        
        // listen
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    // post init property panel
    [propertyController postInitialize:_context];
    
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMainWindowClosed:) name:EDEventWindowWillClose object:[self windowForSheet]];
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
@end
