//
//  EDCoreDataUtility.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDGraph.h"
#import "EDConstants.h"
#import "NSObject+Document.h"

@interface EDCoreDataUtility()
@end

@implementation EDCoreDataUtility
static EDCoreDataUtility *sharedCoreDataUtility = nil;

+ (EDCoreDataUtility *)sharedCoreDataUtility
{
    if (sharedCoreDataUtility == nil) {
        
        sharedCoreDataUtility = [[super allocWithZone:NULL] init];
    }
    return sharedCoreDataUtility;
}

- (NSManagedObjectContext *)context{
    return _context;
}

- (void)setContext: (NSManagedObjectContext *)moc{
    _context = moc; 
}

- (NSMutableArray *)getAllObjects{
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *graphObjects = [self getAllGraphs];
    
#warning add other elements here
    [allObjects addObjectsFromArray:graphObjects];
    
    return allObjects;
}

#pragma mark pages
- (NSArray *)getAllPages{
   // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:_context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // order pages
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [_context executeFetchRequest:request error:&error];   
    //NSLog(@"fetch: %@", mutableFetchResults);
    
    /*
    // handle error
    if (!mutableFetchResults) {   
        // Handle the error.   
        // This is a serious error and should advise the user to restart the application   
    }   
     */
    return fetchResults;
}

- (EDPage *)getLastSelectedPage{
    
    // this method returns a dictionary of the types of selected objects
    NSArray *fetchedObjects;
    
    // get all selected pages ordered by page number
    fetchedObjects = [EDPage findAllSelectedObjectsOrderedByPageNumber];
    if ([fetchedObjects count] > 0) {
        return [fetchedObjects lastObject];
    }
    return nil;
}

- (NSMutableArray *)getAllSelectedPages{
    // gets all pages
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *fetchedGraphs = [EDPage findAllSelectedObjects];
    
    [allObjects addObjectsFromArray:fetchedGraphs];
    
    return allObjects;
}

- (void)deleteSelectedPages{
    NSMutableArray *selectedPages = [self getAllSelectedPages];
    NSLog(@"going to delete selected pages:%@", selectedPages);
    for (EDPage *page in selectedPages){
        NSLog(@"deleting page:%@", page);
#warning for some reason, this delete object takes a while
        [_context deleteObject:page];
    }
}

- (void)correctPageNumbersAfterDelete{
    // gets all pages
    NSArray *fetchedPages = [EDPage findAllObjectsOrderedByPageNumber];
    int currentPageNumber = 1;
    
    NSLog(@"pages returned: %@", fetchedPages);
    // iterate through pages
    for (EDPage *currentPage in fetchedPages){
        if ([[currentPage pageNumber] intValue] != currentPageNumber) {
            NSLog(@"changing page number:%@", currentPage);
            // reset page number to proper number
            [currentPage setValue:[[NSNumber alloc] initWithInt:currentPageNumber] forKey:EDPageAttributePageNumber];
        }
        
        currentPageNumber++;
    }
}

#pragma mark worksheet
- (NSArray *)getAllGraphs{
   // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:_context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [_context executeFetchRequest:request error:&error];   
    //NSLog(@"fetch: %@", mutableFetchResults);
    
    /*
    // handle error
    if (!mutableFetchResults) {   
        // Handle the error.   
        // This is a serious error and should advise the user to restart the application   
    }   
     */
    return fetchResults;
}

- (NSMutableArray *)getAllSelectedObjects{
    // gets all selected objects
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *fetchedGraphs = [EDGraph findAllSelectedObjects];
    
#warning add other elements here
    [allObjects addObjectsFromArray:fetchedGraphs];
    
    return allObjects;
}

- (NSMutableDictionary *)getAllTypesOfSelectedObjects{
    // this method returns a dictionary of the types of selected objects
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSArray *fetchedObjects;
    
    // get all selected graphs
    fetchedObjects = [EDGraph findAllSelectedObjects];
    
#warning add other elements here
    if ([fetchedObjects count] > 0) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDEntityNameGraph]; 
    }
    
         
    return results;
}

- (void)clearSelectedElements{
    NSArray *fetchedObjects = [EDGraph findAllSelectedObjects];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    else{
        for (EDGraph *elem in fetchedObjects){
            [elem setSelected:FALSE];
        }
    }
}

- (void)deleteSelectedElements{
    NSMutableArray *selectedElements = [self getAllSelectedObjects];
    for (EDElement *element in selectedElements){
        [_context deleteObject:element];
    }
}
@end
