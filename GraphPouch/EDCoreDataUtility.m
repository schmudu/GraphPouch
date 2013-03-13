//
//  EDCoreDataUtility.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDConstants.h"
#import "EDEquation.h"
#import "EDGraph.h"
#import "EDLine.h"
#import "EDPage.h"
#import "EDPoint.h"
#import "EDTextbox.h"
#import "EDToken.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDCoreDataUtility()
@end

@implementation EDCoreDataUtility
+ (NSMutableDictionary *)createContext:(NSManagedObjectContext *)startContext{
    NSMutableDictionary *contexts = [[NSMutableDictionary alloc] init];
    // this method will create a child context that will be used throught the program
    // this is so the nspersistentdocumentcontroller won't complain when we save
    NSManagedObjectContext *rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    //NSManagedObjectContext *rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [rootContext setPersistentStoreCoordinator:[startContext persistentStoreCoordinator]];
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    // set root as parent
    [childContext setParentContext:rootContext];
    
    // set undo
    [rootContext setUndoManager:[startContext undoManager]];
    
    [contexts setObject:childContext forKey:EDKeyContextChild];
    [contexts setObject:rootContext forKey:EDKeyContextRoot];
    
    return contexts;
}


+ (BOOL)saveRootContext:(NSManagedObjectContext *)rootContext childContext:(NSManagedObjectContext *)childContext{
    [childContext performBlock:^{
        // do something that takes some time asynchronously using the temp context
        
        // push to parent
        NSError *error;
        if (![childContext save:&error])
        {
            // handle error
            [EDCoreDataUtility validateElements:childContext];
        }
        
        // save parent to disk asynchronously
        /*
        [rootContext performBlock:^{
            NSError *error;
            if (![rootContext save:&error])
            {
                // handle error
                [EDCoreDataUtility validateElements:rootContext];
            }
        }];*/
    }];
    return TRUE;
}

+ (BOOL)validateElements:(NSManagedObjectContext *)context{
#warning worksheet elements
    NSArray *equations = [EDEquation getAllObjects:context];
    NSArray *graphs = [EDGraph getAllObjects:context];
    NSArray *lines = [EDLine getAllObjects:context];
    NSArray *pages = [EDPage getAllObjects:context];
    NSArray *points = [EDPoint getAllObjects:context];
    NSArray *textboxes = [EDTextbox getAllObjects:context];
    NSArray *tokens = [EDToken getAllObjects:context];
    NSMutableArray *allObjects = [NSMutableArray array];
    
    [allObjects addObjectsFromArray:equations];
    [allObjects addObjectsFromArray:graphs];
    [allObjects addObjectsFromArray:lines];
    [allObjects addObjectsFromArray:pages];
    [allObjects addObjectsFromArray:points];
    [allObjects addObjectsFromArray:textboxes];
    [allObjects addObjectsFromArray:tokens];
    
    BOOL result, returnResult = TRUE;
    NSError *error;
    // validate all objects
    for (NSManagedObject *object in allObjects){
        result = [object validateForUpdate:&error];
        
        if (!result) {
            NSLog(@"====error with object:%@\nerror info:%@", error, [error userInfo]);
            
            // set return value
            returnResult = FALSE;
        }
    }
    return returnResult;
}
/*
+ (void)save:(NSManagedObjectContext *)context{
    NSError *error;
    BOOL successfulSave = [context save:&error];
    if (!successfulSave) {
        NSLog(@"error:%@, %@", error, [error userInfo]);
    }
}*/

+ (NSManagedObject *)getObject:(NSManagedObject *)object context:(NSManagedObjectContext *)context{
    // this method returns the page object that matches the page number
    NSArray *fetchedObjects;
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"(SELF == %@)", object];
    NSArray *filteredResults = [fetchedObjects filteredArrayUsingPredicate:searchFilter];;
    return [filteredResults objectAtIndex:0];
}

@end
