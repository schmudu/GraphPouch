//
//  EDCoreDataUtility.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDGraph.h"
#import "EDConstants.h"
#import "NSObject+Document.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSMutableArray+EDPoint.h"
#import "EDEquation.h"
#import "EDToken.h"

@interface EDCoreDataUtility()
@end

@implementation EDCoreDataUtility

+ (void)save:(NSManagedObjectContext *)context{
    NSError *error;
    if ([[[context persistentStoreCoordinator] persistentStores] count] == 0) {
        //add store
        if (![[context persistentStoreCoordinator] addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }    
    }
    else if ([[[context persistentStoreCoordinator] persistentStores] count] == 2) {
        // delete in memory store and continue operating with file store
        NSArray *stores = [[context persistentStoreCoordinator] persistentStores];
        for (NSPersistentStore *store in stores){
            if ([[store type] isEqualToString:@"InMemory"]) {
                // delete store
                [[context persistentStoreCoordinator] removePersistentStore:store error:&error];
                
                // do i have to copy objects out of store?
                NSLog(@"deleting in memory store.");
            }
        }
    }
    BOOL successfulSave = [context save:&error];
    if (!successfulSave) {
        NSLog(@"error:%@, %@", error, [error userInfo]);
    }
}

+ (NSManagedObject *)getObject:(NSManagedObject *)object context:(NSManagedObjectContext *)context{
    // this method returns the page object that matches the page number
    NSArray *fetchedObjects;
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"(SELF == %@)", object];
    NSArray *filteredResults = [fetchedObjects filteredArrayUsingPredicate:searchFilter];;
    return [filteredResults objectAtIndex:0];
}

+ (NSMutableArray *)getAllWorksheetElements:(NSManagedObjectContext *)context{
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    //NSArray *graphObjects = [self getAllGraphs:context];
    NSArray *graphObjects = [EDGraph getAllObjects:context];
    
#warning add other elements here
    [allObjects addObjectsFromArray:graphObjects];
    
    return allObjects;
}

#pragma mark worksheet
+ (NSMutableArray *)copySelectedWorksheetElements:(NSManagedObjectContext *)context{
    // copy all selected objects
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *fetchedGraphs = [EDGraph getAllSelectedObjects:context];
    
    for (EDGraph *graph in fetchedGraphs){
        [allObjects addObject:[graph copy:context]];
    }
#warning add other elements here
    
    return allObjects;
}

+ (NSMutableArray *)getAllSelectedWorksheetElements:(NSManagedObjectContext *)context{
    // gets all selected objects
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *fetchedGraphs = [EDGraph getAllSelectedObjects:context];
    
#warning add other elements here
    [allObjects addObjectsFromArray:fetchedGraphs];
    
    return allObjects;
}

+ (void)insertWorksheetElements:(NSArray *)elements context:(NSManagedObjectContext *)context{
    EDGraph *newGraph;
    //NSLog(@"need to insert elements:%@", elements);
    NSArray *tokens = [EDToken getAllObjects:context];
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    // insert objects into context
    for (EDElement *element in elements){
        [context insertObject:element];
        
        // set element to this page
        if ([element isKindOfClass:[EDGraph class]]){
            newGraph = (EDGraph *)element;
            [newGraph setPage:currentPage];
            
            // get all points that need to be modified
            NSArray *points = [[NSArray alloc] initWithArray:[[newGraph points] allObjects]];
            for (EDPoint *point in points){
                // insert into context
                [context insertObject:point];
                
                // set relationship
                [point setGraph:newGraph];
            }
            
            // get all points that need to be modified
            NSArray *tokens;
            NSArray *equations = [[NSArray alloc] initWithArray:[[newGraph equations] allObjects]];
            
            for (EDEquation *equation in equations){
                // insert into context
                [context insertObject:equation];
                
                // set relationship
                [equation setGraph:newGraph];
                
                // insert tokens as well
                tokens = [[NSArray alloc] initWithArray:[[equation tokens] array]];
                
                // clear any previous tokens
#warning question: i wonder if i have to do this with any ordered set?
                [equation removeTokens:[equation tokens]];
                
                //for (EDToken *token in tokens){
                for (EDToken *token in tokens){
                    // insert token
                    [context insertObject:token];
                    
                    // set relationship
                    [equation addTokensObject:token];
                }
            }
        }
    }
    tokens = [EDToken getAllObjects:context];
}

+ (NSMutableDictionary *)getAllTypesOfSelectedWorksheetElements:(NSManagedObjectContext *)context{
    // this method returns a dictionary of the types of selected objects
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSArray *fetchedObjects;
    
    // get all selected graphs
    fetchedObjects = [EDGraph getAllSelectedObjects:context];
#warning add other elements here
    if ([fetchedObjects count] > 0) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDEntityNameGraph]; 
    }
    
    return results;
}

+ (void)clearSelectedWorksheetElements:(NSManagedObjectContext *)context{
    NSArray *fetchedObjects = [EDGraph getAllSelectedObjects:context];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    else{
        for (EDGraph *elem in fetchedObjects){
            [elem setSelected:FALSE];
        }
    }
}

+ (void)deleteSelectedWorksheetElements:(NSManagedObjectContext *)context{
    NSMutableArray *selectedElements = [self getAllSelectedWorksheetElements:context];
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    
    NSArray *equations = [EDEquation getAllObjects:context];
    NSLog(@"before delete equations:%@", equations);
    for (EDElement *element in selectedElements){
        if ([element isKindOfClass:[EDGraph class]]) {
            [currentPage removeGraphsObject:(EDGraph *)element];
        }
        [context deleteObject:element];
    }
    equations = [EDEquation getAllObjects:context];
    NSLog(@"after delete equations:%@", equations);
}
@end
