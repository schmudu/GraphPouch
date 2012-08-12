//
//  EDCoreDataUtility.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDCoreDataUtility : NSObject{
@private
    //NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *context;
    //NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

+ (EDCoreDataUtility *)sharedCoreDataUtility;
- (void)setContext:(NSManagedObjectContext *)moc;
- (NSManagedObjectContext *)context;
- (NSArray *)getAllObjects;
- (void)clearSelectedElements;
@end
