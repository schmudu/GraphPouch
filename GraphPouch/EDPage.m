//
//  EDPage.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPage.h"
#import "EDGraph.h"
#import "EDPoint.h"
#import "EDEquation.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"

@implementation EDPage

@dynamic currentPage;
@dynamic pageNumber;
@dynamic selected;
@dynamic graphs;

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    // create entity but don't insert it anywhere
    //self = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:nil];
    self = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]];
    if(self){
        [self setCurrentPage:[aDecoder decodeBoolForKey:EDPageAttributeCurrent]];
        [self setPageNumber:[[NSNumber alloc] initWithInt:[aDecoder decodeInt32ForKey:EDPageAttributePageNumber]]];
        [self setSelected:[aDecoder decodeBoolForKey:EDPageAttributeSelected]];
        
        
        EDGraph *newGraph;
        EDPoint *newPoint;
        EDEquation *newEquation;
        NSSet *graphs = [aDecoder decodeObjectForKey:EDPageAttributeGraphs];
        
        for (EDGraph *graph in graphs){
            // create a graph and set it for this page
            newGraph = [[EDGraph alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]];
            
            //set attributes
            [newGraph setElementHeight:[graph elementHeight]];
            [newGraph setElementWidth:[graph elementWidth]];
            [newGraph setHasGridLines:[graph hasGridLines]];
            [newGraph setHasTickMarks:[graph hasTickMarks]];
            [newGraph setLocationX:[graph locationX]];
            [newGraph setLocationY:[graph locationY]];
            [newGraph setSelected:[graph selected]];
 
            // set points for graph
            for (EDPoint *point in [graph points]){
                // create a point and set it for this graph
                newPoint = [[EDPoint alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePoint inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]];
                [newPoint setIsVisible:[point isVisible]];
                [newPoint setShowLabel:[point showLabel]];
                [newPoint setLocationX:[point locationX]];
                [newPoint setLocationY:[point locationY]];
                
                // set graph relationship
                [newGraph addPointsObject:newPoint];
            }
            
            // set equations for graph
            for (EDEquation *equation in [graph equations]){
                // create a point and set it for this graph
                newEquation = [[EDEquation alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameEquation inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]];
                [newEquation setIsVisible:[equation isVisible]];
                [newEquation setShowLabel:[equation showLabel]];
                [newEquation setEquation:[equation equation]];
                
                // set graph relationship
                [newGraph addEquationsObject:newEquation];
            }
            
            // set relationship
            [self addGraphsObject:newGraph];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:[self currentPage] forKey:EDPageAttributeCurrent];
    [aCoder encodeInt:[[self pageNumber] intValue] forKey:EDPageAttributePageNumber];
    [aCoder encodeBool:[self selected] forKey:EDPageAttributeSelected];
    [aCoder encodeObject:[self graphs] forKey:EDPageAttributeGraphs];
}
@end
