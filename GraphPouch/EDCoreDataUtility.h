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
- (NSArray *)getUnselectedPagesWithPageNumberLessThan:(int)upperNumber greaterThanOrEqualTo:(int)lowerNumber;
- (NSArray *)getUnselectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber lessThan:(int)upperNumber;
- (NSArray *)getSelectedPagesWithPageNumberLessThan:(int)upperNumber greaterThanOrEqualTo:(int)lowerNumber;
- (NSArray *)getSelectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber lessThan:(int)upperNumber;



//- (NSArray *)getUnselectedPagesWithPageNumberLessThan:(int)pageNumber greaterThanOrEqualTo:(int)endPageNumber;
- (NSArray *)getPagesWithPageNumberGreaterThan:(int)beginPageNumber;
- (NSArray *)getPagesWithPageNumberGreaterThanOrEqualTo:(int)beginPageNumber lessThan:(int)endPageNumber;
//- (NSArray *)getUnselectedPagesWithPageNumberGreaterThanOrEqualTo:(int)beginPageNumber lessThan:(int)endPageNumber;
- (void)deleteSelectedPages;
- (void)correctPageNumbersAfterDelete;
- (void)removePage:(EDPage *)page;
//- (void)removeObject:(NSManagedObject *)object;
- (void)updatePageNumbersStartingAt:(int)startPageNumber byDifference:(int)difference endNumber:(int)endPageNumber;
//- (EDPage *)getPage:(int)pageNumber;
- (EDPage *)getPage:(EDPage *)page;
- (EDPage *)getCurrentPage;
- (void)setPageAsCurrent:(EDPage *)page;

// graphs
- (NSArray *)getAllGraphs;
@end
