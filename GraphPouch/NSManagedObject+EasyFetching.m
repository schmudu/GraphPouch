//
//  NSManagedObject+EasyFetching.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/5/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSManagedObject+EasyFetching.h"
#import "EDCoreDataUtility.h"

@implementation NSManagedObject (EasyFetching)

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
{
    return [self respondsToSelector:@selector(entityInManagedObjectContext:)] ?
    [self performSelector:@selector(entityInManagedObjectContext:) withObject:context] :
    [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (NSArray *)findAllObjects;
{
    NSManagedObjectContext *context = [[EDCoreDataUtility sharedCoreDataUtility] context];
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


+ (NSArray *)findAllSelectedObjects{
    NSManagedObjectContext *context = [[EDCoreDataUtility sharedCoreDataUtility] context];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
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
/*
 + (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context;
{
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
}*/
@end
