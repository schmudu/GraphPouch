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
    return _context;
}

- (void)setContext: (NSManagedObjectContext *)moc{
    _context = moc; 
}

- (NSSet *)getAllObjects{
    return [_context registeredObjects];
}

- (void)clearSelectedElements{
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
