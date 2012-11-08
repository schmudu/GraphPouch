//
//  EDCoreDataUtility+Points.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/8/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility+Points.h"
#import "EDPoint.h"
#import "EDGraph.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSMutableArray+Utilities.h"
#import "EDConstants.h"

@implementation EDCoreDataUtility (Points)

#pragma mark graph points
- (NSArray *)getAllCommonPointsforSelectedGraphs{
    // get all selected graphs
    NSArray *selectedGraphs = [EDGraph findAllSelectedObjects];
    
    // return if empty
    if ([selectedGraphs count] == 0){
        return nil;
    }
    
    // create dictionary of all the common points
    NSMutableArray *commonPoints = [[NSMutableArray alloc] init];
    
    // add all points in first graph
    for (EDPoint *point in [[selectedGraphs objectAtIndex:0] points]){
        //[commonPoints setObject:point forKey:point];
        [commonPoints addObject:point];
    }
    
    //iterate through graphs
    for (EDGraph *graph in selectedGraphs){
        // if no match
        for (EDPoint *graphPoint in [graph points]){
            if (![commonPoints containsPoint:graphPoint]){
                // no match so remove from common points
                [commonPoints removePoint:graphPoint];
            }
        }
    }
    
    
    // sort common points by x
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationX" ascending:TRUE];
    NSArray *descriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSArray *sortedArray = [commonPoints sortedArrayUsingDescriptors:descriptorArray];
    
    return sortedArray;
}

- (NSArray *)getAllCommonPointsFromSelectedGraphsMatchingPoint:(EDPoint *)matchPoint{
    // get all selected graphs
    NSArray *selectedGraphs = [EDGraph findAllSelectedObjects];
    
    // return if empty
    if ([selectedGraphs count] == 0){
        return nil;
    }
    
    // create dictionary of all the common points
    NSMutableArray *matchingPoints = [[NSMutableArray alloc] init];
    
    //iterate through graphs
    for (EDGraph *graph in selectedGraphs){
        for (EDPoint *point in [graph points]){
            if ([matchPoint matchesPoint:point]){
                [matchingPoints addObject:point];
            }
        }
    }
    
    return matchingPoints;
}

- (void)setAllCommonPointsforSelectedGraphs:(EDPoint *)pointToChange attribute:(NSDictionary *)attributes{
    NSArray *commonPoints = [self getAllCommonPointsFromSelectedGraphsMatchingPoint:pointToChange];
    
    // find points with the same attributes
    for (EDPoint *point in commonPoints){
        // if all attributes match then change the designated attribute
        if ([pointToChange matchesPoint:point]){
            if ([[attributes valueForKey:EDKey] isEqualToString:EDElementAttributeLocationX]) {
                [point setLocationX:[[attributes objectForKey:EDValue] floatValue]];
            }
            else if ([[attributes valueForKey:EDKey] isEqualToString:EDElementAttributeLocationY]) {
                [point setLocationY:[[attributes objectForKey:EDValue] floatValue]];
            }
            else if ([[attributes valueForKey:EDKey] isEqualToString:EDGraphPointAttributeVisible]) {
                [point setIsVisible:[[attributes objectForKey:EDValue] boolValue]];
            }
        }
    }
}

- (void)removeCommonPointsforSelectedGraphsMatchingPoints:(NSArray *)pointsToRemove{
    NSArray *commonPoints = [self getAllCommonPointsforSelectedGraphs];
    NSArray *matchingPoints;
    
    // find points with the same attributes
    for (EDPoint *commonPoint in commonPoints){
        for (EDPoint *deletePoint in pointsToRemove){
            // if all attributes match then delete the designated point
            if ([commonPoint matchesPoint:deletePoint]){
                // get all points in context from selected graphs and delete them
                matchingPoints = [self getAllCommonPointsFromSelectedGraphsMatchingPoint:commonPoint];
                
                // delete all of the points
                for (EDPoint *matchingPoint in matchingPoints){
                    [_context deleteObject:matchingPoint];
                }
            }
        }
    }
}
@end
