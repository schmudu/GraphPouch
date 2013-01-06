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

@interface EDCoreDataUtility()
@end

@implementation EDCoreDataUtility

+ (void)save:(NSManagedObjectContext *)context{
    NSError *error;
    BOOL errorFromSave = [context save:&error];
    NSLog(@"error from save:%@", error);
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
    /*
    NSArray *graphs = [EDGraph getAllObjects:context];
    NSLog(@"before graphs:%@", graphs);
     */
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    // insert objects into context
    for (EDElement *element in elements){
        [context insertObject:element];
        
        // set element to this page
        if ([element isKindOfClass:[EDGraph class]]){
            newGraph = (EDGraph *)element;
            [newGraph setPage:currentPage];
            
            for (EDPoint *point in [newGraph  points]){
                // insert into context
                [context insertObject:point];
                
                // set relationship
                [point setGraph:newGraph];
            }
            NSLog(@"does it have points?:%@", [(EDGraph *)element points]);
        }
    }
    /*
    graphs = [EDGraph getAllObjects:context];
    NSLog(@"after: graphs:%@", graphs);
     */
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
    
    NSArray *graphs = [EDGraph getAllObjects:context];
    NSLog(@"before delete graphs:%@", graphs);
    for (EDElement *element in selectedElements){
        if ([element isKindOfClass:[EDGraph class]]) {
            [currentPage removeGraphsObject:(EDGraph *)element];
        }
        [context deleteObject:element];
    }
    graphs = [EDGraph getAllObjects:context];
    NSLog(@"after delete graphs:%@", graphs);
}
@end
