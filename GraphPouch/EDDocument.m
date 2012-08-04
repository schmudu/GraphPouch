//
//  EDDocument.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDDocument.h"
#import "EDWorksheetViewController.h"
#import "Graph.h"
#import "EDCoreDataUtility.h"

@implementation EDDocument

-(id)getInstance{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        //Init code
    }
    return self;
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
    
    // populate core data utility
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    [coreData setContext: [self managedObjectContext]];
    
    //add listenter
    [elementsController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:(void *)[self managedObjectContext]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [elementsController removeObserver:self forKeyPath:@"arrangedObjects" context:(void *)[self managedObjectContext]];
    
    // data has been loaded ask the worksheet to draw the graphs
    [worksheetController loadDataFromManageObjectContext];
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
/*
- (NSUndoManager *)undoManager{
    // have the undo manager linked to the managed object context
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    return [[coreData context] undoManager];
}*/

/*
// Core Data uses this method to load the file
- (id)initWithContentsOfFile:(NSString *)absolutePath ofType:(NSString *)typeName{
    
}
*/
@end
