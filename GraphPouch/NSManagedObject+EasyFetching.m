//
//  NSManagedObject+EasyFetching.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/5/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSManagedObject+EasyFetching.h"
#import "EDCoreDataUtility.h"
#import "EDConstants.h"

@implementation NSManagedObject (EasyFetching)

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
{
    return [self respondsToSelector:@selector(entityInManagedObjectContext:)] ?
    [self performSelector:@selector(entityInManagedObjectContext:) withObject:context] :
    [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (NSArray *)findAllObjects;
{
    NSManagedObjectContext *context = [self getContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        //handle errors
    }
    return results;
}


+ (NSManagedObject *)findCurrentPage{
    NSManagedObjectContext *context = [self getContext];
    NSEntityDescription *entity;
    
    entity = [self entityDescriptionInContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    // grab relationships
    [request setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:@"graphs"]];
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    // verify that objects actually exist
    if ([objects count] == 0) {
        // if no objects then return empty
        return nil;
    }
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"currentPage = %ld", TRUE];
    NSArray *filteredResults = [objects filteredArrayUsingPredicate:searchFilter];;
    
    //NSArray *results = [[context executeFetchRequest:request error:&error] filteredArrayUsingPredicate:searchFilter];
    if (error != nil)
    {
        //handle errors
    }
    return [filteredResults lastObject];
}

+ (NSArray *)findAllSelectedObjects{
    NSManagedObjectContext *context = [self getContext];
    NSEntityDescription *entity;
    
    entity = [self entityDescriptionInContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    // verify that objects actually exist
    if ([objects count] == 0) {
        // if no objects then return empty
        return objects;
    }
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"selected = %ld", TRUE];
    NSArray *filteredResults = [objects filteredArrayUsingPredicate:searchFilter];;
    
    //NSArray *results = [[context executeFetchRequest:request error:&error] filteredArrayUsingPredicate:searchFilter];
    if (error != nil)
    {
        //handle errors
    }
    return filteredResults;
}

+ (NSArray *)findAllObjectsOrderedByPageNumber{
    NSManagedObjectContext *context = [self getContext];
    NSEntityDescription *entity;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    entity = [self entityDescriptionInContext:context];
    
    // order by page number
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        //handle errors
    }
    return results;
}

+ (NSArray *)findAllSelectedObjectsOrderedByPageNumber{
    NSManagedObjectContext *context = [self getContext];
    NSEntityDescription *entity;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    entity = [self entityDescriptionInContext:context];
    
    // order by page number
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EDPageAttributePageNumber ascending:TRUE];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortArray];
    
    [request setEntity:entity];
    NSError *error = nil;
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"selected = %ld", TRUE];
    NSArray *results = [[context executeFetchRequest:request error:&error] filteredArrayUsingPredicate:searchFilter];
    if (error != nil)
    {
        //handle errors
    }
    return results;
}

#pragma mark context
+ (NSManagedObjectContext *)getContext{
    // by default return document context
    if ([[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]) {
        return [[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext];
    }
    return [[EDCoreDataUtility sharedCoreDataUtility] context];
}
#pragma mark print
+ (void)printAll{
    // print out all pages
    NSManagedObjectContext *context = [self getContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    // print out all pages
    for (NSManagedObject *obj in results){
        NSLog(@"object:%@", obj);
    }
}
@end
