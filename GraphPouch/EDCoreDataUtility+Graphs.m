//
//  EDCoreDataUtility+Graphs.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/16/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility+Graphs.h"
#import "EDGraph.h"
#import "NSManagedObject+EasyFetching.h"

@implementation EDCoreDataUtility (Graphs)

+ (NSArray *)getGraphsForPage:(EDPage *)page context:(NSManagedObjectContext *)context{
    NSArray *graphs = [EDGraph getAllObjects:context];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"(page == %@)", page];
    NSArray *matchingGraphs = [graphs filteredArrayUsingPredicate:searchFilter];
    return matchingGraphs;
}
@end
