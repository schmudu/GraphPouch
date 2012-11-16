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
#import "NSManagedObject+EasyFetching.h"
#import "NSMutableArray+EDPoint.h"

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

- (NSManagedObject *)getObject:(NSManagedObject *)object{
    // this method returns the page object that matches the page number
    NSArray *fetchedObjects;
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"(SELF == %@)", object];
    NSArray *filteredResults = [fetchedObjects filteredArrayUsingPredicate:searchFilter];;
    return [filteredResults objectAtIndex:0];
}

- (NSMutableArray *)getAllWorksheetElements{
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *graphObjects = [self getAllGraphs];
    
#warning add other elements here
    [allObjects addObjectsFromArray:graphObjects];
    
    return allObjects;
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

- (NSMutableArray *)getAllSelectedWorksheetElements{
    // gets all selected objects
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *fetchedGraphs = [EDGraph getAllSelectedObjects];
    
#warning add other elements here
    [allObjects addObjectsFromArray:fetchedGraphs];
    
    return allObjects;
}

- (NSMutableDictionary *)getAllTypesOfSelectedWorksheetElements{
    // this method returns a dictionary of the types of selected objects
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSArray *fetchedObjects;
    
    // get all selected graphs
    fetchedObjects = [EDGraph getAllSelectedObjects];
    
#warning add other elements here
    if ([fetchedObjects count] > 0) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDEntityNameGraph]; 
    }
    
    return results;
}

- (void)clearSelectedWorksheetElements{
    NSArray *fetchedObjects = [EDGraph getAllSelectedObjects];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    else{
        for (EDGraph *elem in fetchedObjects){
            [elem setSelected:FALSE];
        }
    }
}

- (void)deleteSelectedWorksheetElements{
    NSMutableArray *selectedElements = [self getAllSelectedWorksheetElements];
    for (EDElement *element in selectedElements){
        [_context deleteObject:element];
    }
}

@end
