//
//  EDCoreDataUtility.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDPage.h"

@interface EDCoreDataUtility : NSObject{
@private
    //NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *_context;
    //NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

+ (EDCoreDataUtility *)sharedCoreDataUtility;
//+ (NSArray *)findAllSelectedObjects;
- (void)setContext:(NSManagedObjectContext *)moc;
- (void)save;
- (NSManagedObjectContext *)context;
// objects
- (NSMutableArray *)getAllObjects;

// selection
- (NSMutableArray *)getAllSelectedObjects;
- (NSMutableDictionary *)getAllTypesOfSelectedObjects;
- (EDPage *)getLastSelectedPage;
- (void)clearSelectedElements;
- (void)deleteSelectedElements;

// pages
- (NSArray *)getAllPages;
- (NSMutableArray *)getAllSelectedPages;
- (NSArray *)getAllPagesWithPageNumberGreaterThan:(int)pageNumber;
- (void)deleteSelectedPages;
- (void)correctPageNumbersAfterDelete;
- (void)removePage:(EDPage *)page;
- (void)updatePageNumbersStartingAt:(int)startPageNumber forCount:(int)count;
- (EDPage *)getPage:(int)pageNumber;
- (void)setPageAsCurrent:(EDPage *)page;

// graphs
- (NSArray *)getAllGraphs;
@end
