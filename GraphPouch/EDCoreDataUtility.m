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

- (void)save{
    NSError *error;
    BOOL errorFromSave = [_context save:&error];
    NSLog(@"error from save:%@", error);
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

- (EDPage *)getPage:(EDPage *)page{
    // this method returns the page object that matches the page number
    NSArray *fetchedObjects;
    
    // get all selected pages ordered by page number
    fetchedObjects = [EDPage findAllObjectsOrderedByPageNumber];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"(SELF == %@)", page];
    NSArray *filteredResults = [fetchedObjects filteredArrayUsingPredicate:searchFilter];;
    return [filteredResults objectAtIndex:0];
}

/*
- (EDPage *)getPage:(int)pageNumber{
    // this method returns the page object that matches the page number
    NSArray *fetchedObjects;
    
    // get all selected pages ordered by page number
    fetchedObjects = [EDPage findAllObjectsOrderedByPageNumber];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"pageNumber == %ld", pageNumber];
    NSArray *filteredResults = [fetchedObjects filteredArrayUsingPredicate:searchFilter];;
    
    return [filteredResults objectAtIndex:0];
}*/

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
    for (EDPage *page in selectedPages){
#warning for some reason, this delete object takes a while
        [_context deleteObject:page];
    }
    
    // save
    //NSError *error;
    //[_context save:&error];
}

- (void)correctPageNumbersAfterDelete{
    // gets all pages
    NSArray *fetchedPages = [EDPage findAllObjectsOrderedByPageNumber];
    int currentPageNumber = 1;
    
    // iterate through pages
    for (EDPage *currentPage in fetchedPages){
        if ([[currentPage pageNumber] intValue] != currentPageNumber) {
            // reset page number to proper number
            [currentPage setValue:[[NSNumber alloc] initWithInt:currentPageNumber] forKey:EDPageAttributePageNumber];
        }
        
        currentPageNumber++;
    }
}

- (void)updatePageNumbersStartingAt:(int)startPageNumber byDifference:(int)difference endNumber:(int)endPageNumber{
    NSArray *pages = [self getPagesWithPageNumberGreaterThan:startPageNumber lessThan:endPageNumber];
    
    // iterate through pages
    for (EDPage *currentPage in pages){
        // reset page number to proper number
        [currentPage setValue:[[NSNumber alloc] initWithInt:([[currentPage pageNumber] intValue] + difference)] forKey:EDPageAttributePageNumber];
    }
}

//- (void)removeObject:(NSManagedObject *)object{
- (void)removePage:(EDPage *)page{
    // fetch page
    NSManagedObject *managedObj = [self getPage:page];
    NSArray *pages = [EDPage findAllObjectsOrderedByPageNumber];
    NSArray *graphs = [EDGraph findAllObjects];
    NSLog(@"===before deleted:%d page count:%ld graphs count:%ld", [page isDeleted], [pages count], [graphs count]);
    // fetch object
    [_context deleteObject:managedObj];
    
    pages = [EDPage findAllObjectsOrderedByPageNumber];
    graphs = [EDGraph findAllObjects];
    NSLog(@"===after deleted:%d page count:%ld graphs count:%ld", [page isDeleted], [pages count], [graphs count]);
}

- (NSArray *)getPagesWithPageNumberGreaterThan:(int)beginPageNumber{
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
    //NSLog(@"getAllPagesWithPageNumberGreaterThan: fetch: %@", fetchResults);
    
    NSPredicate *beginSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber > %ld", beginPageNumber];
    NSArray *startFilteredResults = [fetchResults filteredArrayUsingPredicate:beginSearchFilter];;
    
    /*
    // handle error
    if (!mutableFetchResults) {   
        // Handle the error.   
        // This is a serious error and should advise the user to restart the application   
    }   
     */
    //NSLog(@"number of pages greater than:%d count:%lu", pageNumber, [filteredResults count]);
    return startFilteredResults;
}

- (NSArray *)getPagesWithPageNumberGreaterThan:(int)beginPageNumber lessThan:(int)endPageNumber{
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
    //NSLog(@"getAllPagesWithPageNumberGreaterThan: fetch: %@", fetchResults);
    
    NSPredicate *beginSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber >= %ld", beginPageNumber];
    NSArray *startFilteredResults = [fetchResults filteredArrayUsingPredicate:beginSearchFilter];;
    
    NSPredicate *endSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber < %ld", endPageNumber];
    NSArray *endFilteredResults = [startFilteredResults filteredArrayUsingPredicate:endSearchFilter];;
    
    /*
    // handle error
    if (!mutableFetchResults) {   
        // Handle the error.   
        // This is a serious error and should advise the user to restart the application   
    }   
     */
    return endFilteredResults;
}

- (EDPage *)getCurrentPage{
    return (EDPage *)[EDPage findCurrentPage];
}

- (void)setPageAsCurrent:(EDPage *)page{
    NSArray *pages = [EDPage findAllObjects];
 
    // get current page
    EDPage *oldCurrentPage = (EDPage *)[EDPage findCurrentPage];
    
    // reset old current page
    if (oldCurrentPage) {
        [oldCurrentPage setCurrentPage:[[[NSNumber alloc] initWithBool:FALSE] boolValue]];
    }
    
    for (EDPage *currentPage in pages){
        if (page == currentPage) {
            [currentPage setCurrentPage:[[[NSNumber alloc] initWithBool:TRUE] boolValue]];
            return;
        }
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
