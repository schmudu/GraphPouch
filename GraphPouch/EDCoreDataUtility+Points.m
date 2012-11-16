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
#import "NSMutableArray+EDPoint.h"
#import "EDConstants.h"
#import "NSSet+Points.h"

@implementation EDCoreDataUtility (Points)

#pragma mark graph points
- (NSArray *)getAllCommonPointsforSelectedGraphs{
    // get all selected graphs
    NSArray *selectedGraphs = [EDGraph getAllSelectedObjects];
    
    // return if empty
    if ([selectedGraphs count] == 0){
        return nil;
    }
    
    // create dictionary of all the common points
    NSMutableArray *commonPoints = [[NSMutableArray alloc] init];
    NSMutableArray *commonPointsToRemove = [[NSMutableArray alloc] init];
    
    // add all points in first graph
    for (EDPoint *point in [[selectedGraphs objectAtIndex:0] points]){
        // reset all matches are visible to TRUE
        [point setMatchesHaveSameVisibility:TRUE];
         
        [commonPoints addObject:point];
    }
    
    //iterate through graphs
    EDPoint *pointFound;
    for (EDGraph *graph in selectedGraphs){
        for (EDPoint *commonPoint in commonPoints){
            // points must be an exact match
            if (![[graph points] containsPoint:commonPoint]){
                // no match so remove from common points
                [commonPointsToRemove addObject:commonPoint];
            }
        }
    }
    /*
    for (EDGraph *graph in selectedGraphs){
        for (EDPoint *commonPoint in commonPoints){
            pointFound = [[graph points] findPointByCoordinate:commonPoint];
            
            if (!pointFound) {
                [commonPointsToRemove addObject:commonPoint];
            }
            else {
                // point was found now see if it was an exact match
                if (![pointFound matchesPoint:commonPoint]) {
                    [commonPoint setMatchesHaveSameVisibility:FALSE];
                }
            }
        }
    }*/
    
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
    NSArray *selectedGraphs = [EDGraph getAllSelectedObjects];
    
    // return if empty
    if ([selectedGraphs count] == 0){
        return nil;
    }
    
    // create dictionary of all the common points
    NSMutableArray *matchingPoints = [[NSMutableArray alloc] init];
    
    //iterate through graphs
    for (EDGraph *graph in selectedGraphs){
        for (EDPoint *point in [graph points]){
            //if ([matchPoint matchesPointByCoordinate:point]){
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
        if ([pointToChange matchesPointByCoordinate:point]){
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
