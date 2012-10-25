//
//  EDPage.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPage.h"
#import "EDGraph.h"
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
        NSLog(@"===graph set:%@", [aDecoder decodeObjectForKey:EDPageAttributeGraphs]);
        
        EDGraph *newGraph;
        for (EDGraph *graph in [aDecoder decodeObjectForKey:EDPageAttributeGraphs]){
            // create a graph and set it for this page
            //NSLog(@"graph:%@", graph);
            //newGraph = [[EDGraph alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:nil];
            newGraph = [[EDGraph alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]];
            
            //set attributes
            [newGraph setEquation:[graph equation]];
            [newGraph setElementHeight:[graph elementHeight]];
            [newGraph setElementWidth:[graph elementWidth]];
            [newGraph setHasGridLines:[graph hasGridLines]];
            [newGraph setHasTickMarks:[graph hasTickMarks]];
            [newGraph setLocationX:[graph locationX]];
            [newGraph setLocationY:[graph locationY]];
            [newGraph setSelected:[graph selected]];
            
            // set relationship
            [newGraph setPage:self];
            [self addGraphsObject:newGraph];
        }
        //[self setGraphs:[[NSSet alloc] initWithSet:[aDecoder decodeObjectForKey:EDPageAttributeGraphs]]];
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
