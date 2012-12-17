//
//  EDCoreDataUtility+Equations.m
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDCoreDataUtility+Equations.h"
#import "EDGraph.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSMutableArray+EDEquation.h"
#import "NSSet+Equations.h"

@implementation EDCoreDataUtility (Equations)

+ (NSArray *)getCommonEquationsforSelectedGraphs:(NSManagedObjectContext *)context{
    // get all selected graphs
    NSArray *selectedGraphs = [EDGraph getAllSelectedObjects:context];
    
    // return if empty
    if ([selectedGraphs count] == 0){
        return nil;
    }
    
    // create dictionary of all the common points
    NSMutableArray *commonEquations = [[NSMutableArray alloc] init];
    NSMutableArray *commonEquationsToRemove = [[NSMutableArray alloc] init];
    
    // add all points in first graph
    for (EDEquation *equation in [[selectedGraphs objectAtIndex:0] equations]){
        [commonEquations addObject:equation];
    }
    //iterate through graphs
    for (EDGraph *graph in selectedGraphs){
        for (EDEquation *commonEquation in commonEquations){
            // points must be an exact match
            if (![[graph equations] containsEquation:commonEquation]){
                // no match so remove from common points
                [commonEquations removeObject:commonEquation];
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
    for (EDEquation *equation in commonEquationsToRemove){
        [commonEquations removeEquation:equation];
    }
    
    // sort common points by x
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDElementAttributeLocationX ascending:TRUE];
    NSArray *descriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSArray *sortedArray = [commonEquations sortedArrayUsingDescriptors:descriptorArray];
    
    return sortedArray;
}

+ (NSArray *)getOneCommonEquationFromSelectedGraphsMatchingEquation:(EDEquation *)matchEquation context:(NSManagedObjectContext *)context{
    // get all selected graphs
    NSArray *selectedGraphs = [EDGraph getAllSelectedObjects:context];
    
    // return if empty
    if ([selectedGraphs count] == 0){
        return nil;
    }
    
    // create dictionary of all the common points
    NSMutableArray *matchingEquations = [[NSMutableArray alloc] init];
    
    //iterate through graphs
    for (EDGraph *graph in selectedGraphs){
        for (EDEquation *equation in [graph equations]){
            if ([matchEquation matchesEquation:equation]){
                // only match one point
                [matchingEquations addObject:equation];
                break;
            }
        }
    }
    
    return matchingEquations;
}

+ (void)setAllCommonEquationsforSelectedGraphs:(EDEquation *)equationToChange attribute:(NSDictionary *)attributes context:(NSManagedObjectContext *)context{
    //NSArray *commonPoints = [self getOneCommonPointFromSelectedGraphsMatchingPoint:pointToChange context:context];
    NSArray *commonEquations = [self getOneCommonEquationFromSelectedGraphsMatchingEquation:equationToChange context:context];
    
    // find points with the same attributes
    for (EDEquation *equation in commonEquations){
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
            else if ([[attributes valueForKey:EDKey] isEqualToString:EDGraphPointAttributeShowLabel]) {
                [point setShowLabel:[[attributes objectForKey:EDValue] boolValue]];
            }
        }
    }
}

+ (void)removeCommonEquationsforSelectedGraphsMatchingEquations:(NSArray *)equationsToRemove context:(NSManagedObjectContext *)context{
    NSArray *matchingPoints;
    
    // find points with the same attributes
    for (EDPoint *deletePoint in pointsToRemove){
        matchingPoints = [self getOneCommonPointFromSelectedGraphsMatchingPoint:deletePoint context:context];
            
        // delete all of the points
        for (EDPoint *matchingPoint in matchingPoints){
            // destroy relationship
            [[matchingPoint graph] removePointsObject:matchingPoint];
            
            // remove object
            [context deleteObject:matchingPoint];
        }
    }
}
@end
