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

@interface EDDocument()
- (void)onMainWindowClosed:(NSNotification *)note;
@end

@implementation EDDocument

-(id)getInstance{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        //Init code
        EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
        [coreData setContext: [self managedObjectContext]];
        propertyController = [[EDPanelPropertiesController alloc] init];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:EDEventWindowWillClose];
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
    [worksheetController setView:worksheetView];
    [worksheetController postInitialize];
    [pagesController postInitialize];
    
    // post init property panel
    [propertyController postInitialize];
    
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
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    return [[coreData context] undoManager];
}

- (void)togglePropertiesPanel:(id)sender{
    [propertyController togglePropertiesPanel:sender];
}

- (BOOL)propertiesPanelIsOpen{
    return [propertyController panelIsOpen];
}

#pragma mark graph
- (IBAction)addPage:(id)sender{
    [pagesController addNewPage];
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
