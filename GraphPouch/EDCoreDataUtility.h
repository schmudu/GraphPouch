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
    NSManagedObjectContext *_context;
    //NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

+ (EDCoreDataUtility *)sharedCoreDataUtility;
//+ (NSArray *)findAllSelectedObjects;
- (void)setContext:(NSManagedObjectContext *)moc;
- (NSManagedObjectContext *)context;
- (NSMutableArray *)getAllObjects;
- (NSArray *)getAllGraphs;
- (void)clearSelectedElements;
@end
