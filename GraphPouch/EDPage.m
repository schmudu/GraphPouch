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
    self = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setCurrentPage:[aDecoder decodeBoolForKey:EDPageAttributeCurrent]];
        [self setPageNumber:[[NSNumber alloc] initWithInt:[aDecoder decodeInt32ForKey:EDPageAttributePageNumber]]];
        [self setSelected:[aDecoder decodeBoolForKey:EDPageAttributeSelected]];
        
        
        EDGraph *newGraph;
        //EDPoint *newPoint;
        NSSet *graphs = [aDecoder decodeObjectForKey:EDPageAttributeGraphs];
        
        for (EDGraph *graph in graphs){
            // create a graph and set it for this page
            newGraph = [[EDGraph alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:[[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]] insertIntoManagedObjectContext:nil];
            
            newGraph = [graph initWithCoder:aDecoder];
            
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
