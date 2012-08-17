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
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onElementsLoaded:) name:NSManagedObjectContextObjectsDidChangeNotification object:[self managedObjectContext]];
    }
    return self;
}

- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL *)url ofType:(NSString *)fileType modelConfiguration:(NSString *)configuration storeOptions:(NSDictionary *)storeOptions error:(NSError *__autoreleasing *)error{
    BOOL result = [super configurePersistentStoreCoordinatorForURL:url ofType:fileType modelConfiguration:configuration storeOptions:storeOptions error:error];
    NSLog(@"read from file: psc: %@", [[[self managedObjectContext] persistentStoreCoordinator] persistentStores]);
    //NSLog(@"read from file: objects: %@", [[EDCoreDataUtility sharedCoreDataUtility] getAllObjects]);
    return result;
    //return [super configurePersistentStoreCoordinatorForURL:url ofType:fileType modelConfiguration:configuration storeOptions:storeOptions error:error];
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
    [worksheetController initListeners];
    //NSLog(@"worksheet controller view: %@", [worksheetController view]);
    //NSLog(@"elements: %@", [[EDCoreDataUtility sharedCoreDataUtility] getAllObjects]);
    // populate core data utility
    //EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    //[coreData setContext: [self managedObjectContext]];
    
    //add listenter
    //[elementsController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:(void *)[self managedObjectContext]];
    [self fetchRecords];
}

- (void)fetchRecords{
    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EDGraph" inManagedObjectContext:[self managedObjectContext]];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // Define how we will sort the records   
    /*
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];   
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];   
    [request setSortDescriptors:sortDescriptors];    
    [sortDescriptor release];   
    */
    // Fetch the records and handle an error   
    NSError *error;   
    NSMutableArray *mutableFetchResults = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];   
    NSLog(@"fetch: %@", mutableFetchResults);
    
    if (!mutableFetchResults) {   
        // Handle the error.   
        // This is a serious error and should advise the user to restart the application   
    }   
}

- (void)onElementsLoaded{
    // remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[self managedObjectContext]];
    NSLog(@"elements loaded.");
}

- (void)awakeFromNib{
    // code that happens before windowControllerDidLoadNib
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //[elementsController removeObserver:self forKeyPath:@"arrangedObjects" context:(void *)[self managedObjectContext]];
    
    // data has been loaded ask the worksheet to draw the graphs
    //[worksheetController loadDataFromManageObjectContext];
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
