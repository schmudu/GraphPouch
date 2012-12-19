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
#import "EDToken.h"

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
        [equation setMatchesHaveSameVisibility:TRUE];
        [equation setMatchesHaveSameLabel:TRUE];
        [commonEquations addObject:equation];
    }
    
    EDEquation *equationFound;
    for (EDGraph *graph in selectedGraphs){
        for (EDEquation *commonEquation in commonEquations){
            equationFound = [[graph equations] findEquation:commonEquation];
            
            if (!equationFound) {
                [commonEquationsToRemove addObject:commonEquation];
            }
            else {
                // point was found now see if it was an exact match
                if ([equationFound isVisible] != [commonEquation isVisible]) {
                    [commonEquation setMatchesHaveSameVisibility:FALSE];
                }
                
                if ([equationFound showLabel] != [commonEquation showLabel]) {
                    [commonEquation setMatchesHaveSameLabel:FALSE];
                }
            }
        }
    }
    
    // remove points that weren't common to all graphs
    for (EDEquation *equation in commonEquationsToRemove){
        [commonEquations removeEquation:equation];
    }
    
    return commonEquations;
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
        if ([equationToChange matchesEquation:equation]){
            // set string value
            if ([[attributes valueForKey:EDKey] isEqualToString:EDEquationAttributeEquation]) {
                [equation setValue:[[attributes objectForKey:EDValue] string]];
                
                // need to set all the tokens also
                [equation removeAllTokens];
                
                // copy all tokens from equation that changed to other equations
                EDToken *tokenCopy;
                for (EDToken *token in [equationToChange tokens]){
                    // copy token
                    tokenCopy = [token copy:context];
                    
                    // add to equation
                    [equation addTokensObject:tokenCopy];
                }
            }
            else if ([[attributes valueForKey:EDKey] isEqualToString:EDEquationAttributeIsVisible]) {
                [equation setIsVisible:[[attributes objectForKey:EDValue] boolValue]];
            }
            else if ([[attributes valueForKey:EDKey] isEqualToString:EDEquationAttributeShowLabel]) {
                [equation setShowLabel:[[attributes objectForKey:EDValue] boolValue]];
            }
        }
    }
}

+ (void)removeCommonEquationsforSelectedGraphsMatchingEquations:(NSArray *)equationsToRemove context:(NSManagedObjectContext *)context{
    NSArray *matchingEquations;
    
    // find points with the same attributes
    for (EDEquation *deleteEquation in equationsToRemove){
        matchingEquations = [self getOneCommonEquationFromSelectedGraphsMatchingEquation:deleteEquation context:context];
            
        // delete all of the points
        for (EDEquation *matchingEquation in matchingEquations){
            // destroy relationship
            [[matchingEquation graph] removeEquationsObject:matchingEquation];
            
            // remove object
            [context deleteObject:matchingEquation];
        }
    }
}
@end
