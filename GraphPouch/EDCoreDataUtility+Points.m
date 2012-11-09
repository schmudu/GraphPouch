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
#import "NSSet+Points.h"

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
    NSMutableArray *commonPointsToRemove = [[NSMutableArray alloc] init];
    
    // add all points in first graph
    for (EDPoint *point in [[selectedGraphs objectAtIndex:0] points]){
        //[commonPoints setObject:point forKey:point];
        [commonPoints addObject:point];
    }
    
    //iterate through graphs
    for (EDGraph *graph in selectedGraphs){
        for (EDPoint *commonPoint in commonPoints){
            //NSLog(@"checking if common points:%@ contains point:%@ result:%d", commonPoints, graphPoint, [commonPoints containsPoint:graphPoint]);
            if (![[graph points] containsPoint:commonPoint]){
                // no match so remove from common points
                [commonPointsToRemove addObject:commonPoint];
            }
        }
    }
    
    // remove points that weren't common to all graphs
    for (EDPoint *point in commonPointsToRemove){
        [commonPoints removePoint:point];
    }
    
    // sort common points by x
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDElementAttributeLocationX ascending:TRUE];
    NSArray *descriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSArray *sortedArray = [commonPoints sortedArrayUsingDescriptors:descriptorArray];
    
    return sortedArray;
}

- (NSArray *)getOneCommonPointFromSelectedGraphsMatchingPoint:(EDPoint *)matchPoint{
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
                // only match one point
                [matchingPoints addObject:point];
                break;
            }
        }
    }
    
    return matchingPoints;
}

- (void)setAllCommonPointsforSelectedGraphs:(EDPoint *)pointToChange attribute:(NSDictionary *)attributes{
    NSArray *commonPoints = [self getOneCommonPointFromSelectedGraphsMatchingPoint:pointToChange];
    
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
   // NSArray *commonPoints = [self getAllCommonPointsforSelectedGraphs];
    NSArray *matchingPoints;
    
    // find points with the same attributes
    for (EDPoint *deletePoint in pointsToRemove){
        matchingPoints = [self getOneCommonPointFromSelectedGraphsMatchingPoint:deletePoint];
            
        // delete all of the points
        for (EDPoint *matchingPoint in matchingPoints){
            // destroy relationship
            [[matchingPoint graph] removePointsObject:matchingPoint];
            
            // remove object
            [_context deleteObject:matchingPoint];
        }
    }
}
@end
