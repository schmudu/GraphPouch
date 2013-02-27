//
//  EDCoreDataUtility+Pages.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility+Pages.h"
#import "EDCoreDataUtility+Worksheet.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"
#import "EDEquation.h"
#import "EDGraph.h"
#import "EDLine.h"
#import "EDTextbox.h"
#import "EDToken.h"
#import "NSManagedObject+EasyFetching.h"

@implementation EDCoreDataUtility (Pages)

#pragma mark pages
+ (void)selectAllPages:(NSManagedObjectContext *)context{

    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // Fetch the records and handle an error
    NSError *error;   
    NSArray *pages = [context executeFetchRequest:request error:&error];
    
    for (EDPage *page in pages){
        [page setSelected:TRUE];
    }
}

+ (void)deselectAllPages:(NSManagedObjectContext *)context{

    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // Fetch the records and handle an error
    NSError *error;   
    NSArray *pages = [context executeFetchRequest:request error:&error];
    
    for (EDPage *page in pages){
        [page setSelected:FALSE];
    }
}

+ (NSArray *)getAllPages:(NSManagedObjectContext *)context{
    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // order pages
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];   
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

+ (EDPage *)getPageWithNumber:(int)pageNumber context:(NSManagedObjectContext *)context{
    // this method returns the page object that matches the page number
    NSArray *fetchedObjects;
    
    // get all selected pages ordered by page number
    fetchedObjects = [EDPage getAllObjectsOrderedByPageNumber:context];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"(pageNumber == %d)", pageNumber];
    NSArray *filteredResults = [fetchedObjects filteredArrayUsingPredicate:searchFilter];
    if ([filteredResults count] == 0) {
        return nil;
    }
    return [filteredResults objectAtIndex:0];
}

+ (EDPage *)getPage:(EDPage *)page context:(NSManagedObjectContext *)context{
    // this method returns the page object that matches the page number
    NSArray *fetchedObjects;
    
    // get all selected pages ordered by page number
    fetchedObjects = [EDPage getAllObjectsOrderedByPageNumber:context];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"(SELF == %@)", page];
    NSArray *filteredResults = [fetchedObjects filteredArrayUsingPredicate:searchFilter];
    return [filteredResults objectAtIndex:0];
}

+ (EDPage *)getLastSelectedPage:(NSManagedObjectContext *)context{
    
    // this method returns a dictionary of the types of selected objects
    NSArray *fetchedObjects;
    
    // get all selected pages ordered by page number
    fetchedObjects = [EDPage getAllSelectedObjectsOrderedByPageNumber:context];
    if ([fetchedObjects count] > 0) {
        return [fetchedObjects lastObject];
    }
    return nil;
}

+ (EDPage *)getLastPage:(NSManagedObjectContext *)context{
    // this method returns a dictionary of the types of selected objects
    NSArray *fetchedObjects;
    
    // get all selected pages ordered by page number
    fetchedObjects = [EDPage getAllObjectsOrderedByPageNumber:context];
    if ([fetchedObjects count] > 0) {
        return [fetchedObjects lastObject];
    }
    return nil;
}

+ (EDPage *)getFirstPage:(NSManagedObjectContext *)context{
    // this method returns a dictionary of the types of selected objects
    NSArray *fetchedObjects;
    
    // get all selected pages ordered by page number
    fetchedObjects = [EDPage getAllObjectsOrderedByPageNumber:context];
    if ([fetchedObjects count] > 0) {
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
}

+ (NSMutableArray *)getAllSelectedPages:(NSManagedObjectContext *)context{
    // gets all pages
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *fetchedGraphs = [EDPage getAllSelectedObjects:context];
    
    [allObjects addObjectsFromArray:fetchedGraphs];
    
    return allObjects;
}

+ (void)deleteSelectedPages:(NSManagedObjectContext *)context{
    NSMutableArray *selectedPages = [self getAllSelectedPages:context];
    for (EDPage *page in selectedPages){
        [context deleteObject:page];
    }
    
    // save
    //NSError *error;
    //[_context save:&error];
}

+ (void)correctPageNumbersAfterDelete:(NSManagedObjectContext *)context{
    // gets all pages
    NSArray *fetchedPages = [EDPage getAllObjectsOrderedByPageNumber:context];
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

+ (void)updatePageNumbersStartingAt:(int)startPageNumber byDifference:(int)difference endNumber:(int)endPageNumber context:(NSManagedObjectContext *)context{
    NSArray *pages = [self getPagesWithPageNumberGreaterThanOrEqualTo:startPageNumber lessThan:endPageNumber context:context];
    
    // iterate through pages
    for (EDPage *currentPage in pages){
        // reset page number to proper number
        [currentPage setValue:[[NSNumber alloc] initWithInt:([[currentPage pageNumber] intValue] + difference)] forKey:EDPageAttributePageNumber];
    }
}

+ (void)removePage:(EDPage *)page context:(NSManagedObjectContext *)context{
    // fetch page
    NSManagedObject *managedObj = [self getPage:page context:context];
    
    // fetch object
    [context deleteObject:managedObj];
}

+ (NSArray *)getPagesWithPageNumberGreaterThanOrEqualTo:(int)beginPageNumber context:(NSManagedObjectContext *)context{
    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // order pages
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];   
    //NSLog(@"getAllPagesWithPageNumberGreaterThan: fetch: %@", fetchResults);
    
    NSPredicate *beginSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber >= %ld", beginPageNumber];
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

+ (NSArray *)getPagesWithPageNumberGreaterThan:(int)beginPageNumber context:(NSManagedObjectContext *)context{
    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // order pages
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];   
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

+ (NSArray *)getUnselectedPagesWithPageNumberLessThan:(int)upperNumber greaterThanOrEqualTo:(int)lowerNumber context:(NSManagedObjectContext *)context{
    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // order pages
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];   
    //NSLog(@"getAllPagesWithPageNumberGreaterThan: fetch: %@", fetchResults);
    
    NSPredicate *beginSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber < %ld", upperNumber];
    NSArray *startFilteredResults = [fetchResults filteredArrayUsingPredicate:beginSearchFilter];;
    
    NSPredicate *endSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber >= %ld", lowerNumber];
    NSArray *endFilteredResults = [startFilteredResults filteredArrayUsingPredicate:endSearchFilter];
    
    NSPredicate *unselectedSearchFilter = [NSPredicate predicateWithFormat:@"selected = %ld", FALSE];
    NSArray *unselectedFilteredResults = [endFilteredResults filteredArrayUsingPredicate:unselectedSearchFilter];;
    
    /*
     // handle error
     if (!mutableFetchResults) {   
     // Handle the error.   
     // This is a serious error and should advise the user to restart the application   
     }   
     */
    //NSLog(@"number of pages greater than:%d count:%lu", pageNumber, [filteredResults count]);
    return unselectedFilteredResults;
}

+ (NSArray *)getUnselectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber context:(NSManagedObjectContext *)context{
    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // order pages
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];   
    //NSLog(@"getAllPagesWithPageNumberGreaterThan: fetch: %@", fetchResults);
    
    NSPredicate *beginSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber >= %ld", lowerNumber];
    NSArray *startFilteredResults = [fetchResults filteredArrayUsingPredicate:beginSearchFilter];
    
    NSPredicate *selectedSearchFilter = [NSPredicate predicateWithFormat:@"selected = %ld", FALSE];
    NSArray *selectedFilteredResults = [startFilteredResults filteredArrayUsingPredicate:selectedSearchFilter];;
    
    /*
     // handle error
     if (!mutableFetchResults) {   
     // Handle the error.   
     // This is a serious error and should advise the user to restart the application   
     }   
     */
    //NSLog(@"number of pages greater than:%d count:%lu", pageNumber, [filteredResults count]);
    return selectedFilteredResults;
}

+ (NSArray *)getUnselectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber lessThan:(int)upperNumber context:(NSManagedObjectContext *)context{
    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // order pages
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];   
    //NSLog(@"getAllPagesWithPageNumberGreaterThan: fetch: %@", fetchResults);
    
    NSPredicate *beginSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber >= %ld", lowerNumber];
    NSArray *startFilteredResults = [fetchResults filteredArrayUsingPredicate:beginSearchFilter];
    
    NSPredicate *endSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber < %ld", upperNumber];
    NSArray *endFilteredResults = [startFilteredResults filteredArrayUsingPredicate:endSearchFilter];
    
    NSPredicate *selectedSearchFilter = [NSPredicate predicateWithFormat:@"selected = %ld", FALSE];
    NSArray *selectedFilteredResults = [endFilteredResults filteredArrayUsingPredicate:selectedSearchFilter];;
    
    /*
     // handle error
     if (!mutableFetchResults) {   
     // Handle the error.   
     // This is a serious error and should advise the user to restart the application   
     }   
     */
    //NSLog(@"number of pages greater than:%d count:%lu", pageNumber, [filteredResults count]);
    return selectedFilteredResults;
}

+ (NSArray *)getSelectedPagesWithPageNumberLessThan:(int)upperNumber greaterThanOrEqualTo:(int)lowerNumber context:(NSManagedObjectContext *)context{
    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // order pages
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];   
    //NSLog(@"getAllPagesWithPageNumberGreaterThan: fetch: %@", fetchResults);
    
    NSPredicate *beginSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber < %ld", upperNumber];
    NSArray *startFilteredResults = [fetchResults filteredArrayUsingPredicate:beginSearchFilter];;
    
    NSPredicate *endSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber >= %ld", lowerNumber];
    NSArray *endFilteredResults = [startFilteredResults filteredArrayUsingPredicate:endSearchFilter];
    
    NSPredicate *selectedSearchFilter = [NSPredicate predicateWithFormat:@"selected = %ld", TRUE];
    NSArray *selectedFilteredResults = [endFilteredResults filteredArrayUsingPredicate:selectedSearchFilter];;
    
    /*
     // handle error
     if (!mutableFetchResults) {   
     // Handle the error.   
     // This is a serious error and should advise the user to restart the application   
     } */  
    //NSLog(@"number of pages greater than:%d count:%lu", pageNumber, [filteredResults count]);
    return selectedFilteredResults;
}

+ (NSArray *)getSelectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber lessThan:(int)upperNumber context:(NSManagedObjectContext *)context{
    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // order pages
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];   
    //NSLog(@"getAllPagesWithPageNumberGreaterThan: fetch: %@", fetchResults);
    
    NSPredicate *beginSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber >= %ld", lowerNumber];
    NSArray *startFilteredResults = [fetchResults filteredArrayUsingPredicate:beginSearchFilter];;
    
    NSPredicate *endSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber < %ld", upperNumber];
    NSArray *endFilteredResults = [startFilteredResults filteredArrayUsingPredicate:endSearchFilter];
    
    NSPredicate *selectedSearchFilter = [NSPredicate predicateWithFormat:@"selected = %ld", TRUE];
    NSArray *selectedFilteredResults = [endFilteredResults filteredArrayUsingPredicate:selectedSearchFilter];;
    
    /*
     // handle error
     if (!mutableFetchResults) {   
     // Handle the error.   
     // This is a serious error and should advise the user to restart the application   
     }   
     */
    //NSLog(@"number of pages greater than:%d count:%lu", pageNumber, [filteredResults count]);
    return selectedFilteredResults;
}



+ (NSArray *)getPagesWithPageNumberGreaterThanOrEqualTo:(int)beginPageNumber lessThan:(int)endPageNumber context:(NSManagedObjectContext *)context{
    // Define our table/entity to use   
    NSEntityDescription *entity = [NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context];   
    
    // Setup the fetch request   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];   
    [request setEntity:entity];   
    
    // order pages
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    // Fetch the records and handle an error   
    NSError *error;   
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];   
    //NSLog(@"getAllPagesWithPageNumberGreaterThan: fetch: %@", fetchResults);
    
    NSPredicate *beginSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber >= %ld", beginPageNumber];
    NSArray *startFilteredResults = [fetchResults filteredArrayUsingPredicate:beginSearchFilter];;
    
    NSPredicate *endSearchFilter = [NSPredicate predicateWithFormat:@"pageNumber < %ld", endPageNumber];
    NSArray *endFilteredResults = [startFilteredResults filteredArrayUsingPredicate:endSearchFilter];;
    
    // handle error
    /*
     if (!mutableFetchResults) {   
     // Handle the error.   
     // This is a serious error and should advise the user to restart the application   
     } */  
    return endFilteredResults;
}

+ (EDPage *)getCurrentPage:(NSManagedObjectContext *)context{
    return (EDPage *)[EDPage getCurrentPage:context];
}

+ (void)setPageAsCurrent:(EDPage *)page context:(NSManagedObjectContext *)context{
    // unset previous current page
    EDPage *previousPage = (EDPage *)[EDPage getCurrentPage:context];
    
    // if already set then do nothing
    if (previousPage == page){
        return;
    }
    // clear any selection of worksheet elements
    [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:context];
    
    // unset previous page as current
    [previousPage setCurrentPage:FALSE];
    
    // set parameter as current page
    EDPage *newPage = [self getPage:page context:context];
    [newPage setCurrentPage:TRUE];
    
    // clear any selection of pages
    [EDCoreDataUtility deselectAllPages:context];
    
    // set this page as selected
    [newPage setSelected:TRUE];
}

+ (void)insertPages:(NSArray *)pages atPosition:(int)insertPosition pagesToUpdate:(NSArray *)pagesToUpdate context:(NSManagedObjectContext *) context{
    int startInsertPosition = insertPosition;
    if ([pages count] > 0) {
        // cycle through objects and insert after last selected page
        for (EDPage *page in pages){
            EDPage *newPage = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:context] insertIntoManagedObjectContext:context];
            //[context insertObject:page];
            [newPage copyAttributes:page];
            
            // update each page view with it's new position
            [newPage setPageNumber:[[NSNumber alloc] initWithInt:startInsertPosition]];
            
            // get all graphs that need to be modified
            NSArray *graphs = [[NSArray alloc] initWithArray:[[page graphs] allObjects]];
            NSArray *lines = [[NSArray alloc] initWithArray:[[page lines] allObjects]];
            NSArray *textboxes = [[NSArray alloc] initWithArray:[[page textboxes] allObjects]];
            
#warning worksheet elements
            for (EDGraph *graph in graphs){
                EDGraph *newGraph = [[EDGraph alloc] initWithContext:context];
                [context insertObject:newGraph];
                [newGraph copyAttributes:graph];
                [newGraph setPage:newPage];
                
                // get all points that need to be modified
                NSArray *points = [[NSArray alloc] initWithArray:[[graph points] allObjects]];
                for (EDPoint *point in points){
                    // insert into context
                    [context insertObject:point];
                    
                    // set relationship
                    [point setGraph:newGraph];
                }
                
                // get all points that need to be modified
                NSArray *tokens;
                NSArray *equations = [[NSArray alloc] initWithArray:[[graph equations] allObjects]];
                
                for (EDEquation *equation in equations){
                    // insert into context
                    [context insertObject:equation];
                    
                    // set relationship
                    [equation setGraph:newGraph];
                    
                    // insert tokens as well
                    tokens = [[NSArray alloc] initWithArray:[[equation tokens] array]];
                    
                    // clear any previous tokens
                    [equation removeTokens:[equation tokens]];
                    
                    for (EDToken *token in tokens){
                        // insert token
                        [context insertObject:token];
                        
                        // set relationship
                        [equation addTokensObject:token];
                    }
                }
            }
            
            // lines
            for (EDLine *line in lines){
                // insert into context
                [context insertObject:line];
            
                // set relationship
                [line setPage:newPage];
            }
            
            // textboxes
            for (EDTextbox *textbox in textboxes){
                // insert into context
                [context insertObject:textbox];
            
                // set relationship
                [textbox setPage:newPage];
            }
            startInsertPosition++;
            
            
            // done with source page, now we can delete it
            [context deleteObject:page];
        }
        
        // update each page view with it's new position
        for (EDPage *page in pagesToUpdate){
            [page setPageNumber:[[NSNumber alloc] initWithInt:(insertPosition + (int)[pages count])]];
            insertPosition++;
        }
    }
}
@end
