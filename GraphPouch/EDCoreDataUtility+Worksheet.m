//
//  EDCoreDataUtility+Worksheet.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/12/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility+Worksheet.h"
#import "EDGraph.h"
#import "EDEquation.h"
#import "EDToken.h"
#import "NSObject+Document.h"
#import "EDCoreDataUtility+Pages.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSMutableArray+EDPoint.h"
#import "EDElement.h"

@implementation EDCoreDataUtility (Worksheet)

+ (NSMutableArray *)getAllWorksheetElements:(NSManagedObjectContext *)context{
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    //NSArray *graphObjects = [self getAllGraphs:context];
    NSArray *graphObjects = [EDGraph getAllObjects:context];
#warning it doesn't make sense to get all the objects.  I think we should remove this method
    
#warning add other elements here
    [allObjects addObjectsFromArray:graphObjects];
    
    return allObjects;
}


+ (void)selectAllWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context{
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSArray *objects = [currentPage getAllWorksheetObjects];
    
    for (EDElement *element in objects){
        // set every element as selected
        [element setSelected:TRUE];
    }
}

+ (void)selectNextWorksheetElementOnCurrentPage:(NSManagedObjectContext *)context{
    // get all selected objects on current page
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSArray *selectedObjects = [currentPage getAllSelectedWorksheetObjects];
    NSArray *allObjects = [currentPage getAllWorksheetObjects];
    if (([selectedObjects count] > 1) || ([selectedObjects count] == 0)){
        // clear selection of all objects
        [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
        
        // select the first object in the page
        [(EDElement *)[allObjects objectAtIndex:0] setSelected:TRUE];
    }
    else{
        //get index of currently selected object then get the next object
        EDElement *matchingObject = (EDElement *)[selectedObjects objectAtIndex:0];
        int i=0, j=0;
        for (EDElement *element in allObjects){
            if (element == matchingObject)
                break;
            
            i++;
        }
        
        // clear selection
        [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
        
        // match the very next object
        i++;
        // wrap-around
        if (i == [allObjects count]){
            // clear selection of all objects
            [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
            
            // select the first object in the page
            [(EDElement *)[allObjects objectAtIndex:0] setSelected:TRUE];
        }
        else{
            // select the very next element in the array
            for (EDElement *element in allObjects){
                // match the next element
                if (j == i){
                    [element setSelected:TRUE];
                    break;
                }
                
                j++;
            }
        }
    }
}

+ (void)selectPreviousWorksheetElementOnCurrentPage:(NSManagedObjectContext *)context{

    // get all selected objects on current page
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSArray *selectedObjects = [currentPage getAllSelectedWorksheetObjects];
    NSArray *allObjects = [currentPage getAllWorksheetObjects];
    if (([selectedObjects count] > 1) || ([selectedObjects count] == 0)){
        // clear selection of all objects
        [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
        
        // select the first object in the page
        [(EDElement *)[allObjects objectAtIndex:0] setSelected:TRUE];
    }
    else{
        //get index of currently selected object then get the next object
        EDElement *matchingObject = (EDElement *)[selectedObjects objectAtIndex:0];
        int i=0, j=0;
        for (EDElement *element in allObjects){
            if (element == matchingObject)
                break;
            
            i++;
        }
        
        // clear selection
        [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
        
        // match the previous object
        i--;
        
        // wrap-around
        if (i == -1){
            // clear selection of all objects
            [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
            
            // select the first object in the page
            [(EDElement *)[allObjects lastObject] setSelected:TRUE];
        }
        else{
            // select the very next element in the array
            for (EDElement *element in allObjects){
                // match the next element
                if (j == i){
                    [element setSelected:TRUE];
                    break;
                }
                
                j++;
            }
        }
    }
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

+ (void)deselectAllSelectedWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context{
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
    
    /*
    NSArray *equations = [EDEquation getAllObjects:context];
    NSLog(@"before delete equations:%@", equations);
     */
    for (EDElement *element in selectedElements){
        if ([element isKindOfClass:[EDGraph class]]) {
            [currentPage removeGraphsObject:(EDGraph *)element];
        }
        [context deleteObject:element];
    }
    /*
    equations = [EDEquation getAllObjects:context];
    NSLog(@"after delete equations:%@", equations);
     */
}
@end
