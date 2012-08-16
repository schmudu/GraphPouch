//
//  EDCoreDataUtility.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDGraph.h"

@implementation EDCoreDataUtility
static EDCoreDataUtility *sharedCoreDataUtility = nil;

+ (EDCoreDataUtility *)sharedCoreDataUtility
{
    if (sharedCoreDataUtility == nil) {
        
        sharedCoreDataUtility = [[super allocWithZone:NULL] init];
    }
    return sharedCoreDataUtility;
}

- (NSManagedObjectContext *)context{
    return context;
}

- (void)setContext: (NSManagedObjectContext *)moc{
    //NSLog(@"context: %@", moc);
    context = moc; 
}

- (NSArray *)getAllObjects{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EDGraph"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    else{
        for (id elem in fetchedObjects){
            NSLog(@"elem: %f", [(EDGraph *)elem locationX]);
        }
        return fetchedObjects;
    }
    return fetchedObjects;
}

- (void)clearSelectedElements{
    /*
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EDGraph"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
     */
    //NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSArray *fetchedObjects = [EDGraph findAllSelectedObjects];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    else{
        for (EDGraph *elem in fetchedObjects){
            NSLog(@"setting to unselected: %@", elem);
            [elem setSelected:FALSE];
        }
    }
}
@end