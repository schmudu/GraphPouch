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
    NSLog(@"special: context:%@", context);
    return [self respondsToSelector:@selector(entityInManagedObjectContext:)] ?
    [self performSelector:@selector(entityInManagedObjectContext:) withObject:context] :
    [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (NSArray *)findAllObjects;
{
    NSManagedObjectContext *context = [[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext];
    //NSManagedObjectContext *context = [[EDCoreDataUtility sharedCoreDataUtility] context];
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
    NSManagedObjectContext *context = [[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext];
    NSEntityDescription *entity;
    
    // if current document is not key window then revert to shared core data
    // default, get context from document
    if (context != nil) {
        entity = [self entityDescriptionInContext:context];
    }
    else {
        context = [[EDCoreDataUtility sharedCoreDataUtility] context];
        entity = [self entityDescriptionInContext:context];
    }
    
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
@end
