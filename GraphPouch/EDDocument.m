//
//  EDDocument.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDDocument.h"
#import "EDWorksheetViewController.h"
#import "EDGraph.h"
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
        EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
        [coreData setContext: [self managedObjectContext]];
        NSLog(@"init EDDocument:");
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
    NSLog(@"window controller did load nib. making worksheet controller init view");
    [worksheetController setView:worksheetView];
    [worksheetController postInitialize];
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
@end
