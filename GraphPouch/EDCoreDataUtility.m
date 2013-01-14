//
//  EDCoreDataUtility.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDConstants.h"

@interface EDCoreDataUtility()
@end

@implementation EDCoreDataUtility
+ (NSMutableDictionary *)createContext:(NSManagedObjectContext *)startContext{
    NSMutableDictionary *contexts = [[NSMutableDictionary alloc] init];
    // this method will create a child context that will be used throught the program
    // this is so the nspersistentdocumentcontroller won't complain when we save
    NSManagedObjectContext *rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [rootContext setPersistentStoreCoordinator:[startContext persistentStoreCoordinator]];
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    // set root as parent
    [childContext setParentContext:rootContext];
    
    // set root as context for coordinator
    //[[startContext persistentStoreCoordinator] 
    
    // set undo
    [childContext setUndoManager:[startContext undoManager]];
    
    NSLog(@"root context:%@ child context:%@", rootContext, childContext);
    
    [contexts setObject:childContext forKey:EDKeyContextChild];
    [contexts setObject:rootContext forKey:EDKeyContextRoot];
    
    return contexts;
}

+ (void)save:(NSManagedObjectContext *)context{
    NSError *error;
    BOOL successfulSave = [context save:&error];
    if (!successfulSave) {
        NSLog(@"error:%@, %@", error, [error userInfo]);
    }
}

+ (NSManagedObject *)getObject:(NSManagedObject *)object context:(NSManagedObjectContext *)context{
    // this method returns the page object that matches the page number
    NSArray *fetchedObjects;
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"(SELF == %@)", object];
    NSArray *filteredResults = [fetchedObjects filteredArrayUsingPredicate:searchFilter];;
    return [filteredResults objectAtIndex:0];
}

@end
