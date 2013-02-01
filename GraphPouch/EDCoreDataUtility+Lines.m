//
//  EDCoreDataUtility+Lines.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility+Lines.h"
#import "EDLine.h"
#import "NSManagedObject+EasyFetching.h"

@implementation EDCoreDataUtility (Lines)

+ (NSArray *)getLinesForPage:(EDPage *)page context:(NSManagedObjectContext *)context{
    NSArray *lines = [EDLine getAllObjects:context];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"(page == %@)", page];
    NSArray *matchingLines = [lines filteredArrayUsingPredicate:searchFilter];
    return matchingLines;
}
@end
