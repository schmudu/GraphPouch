//
//  EDCoreDataUtility+Pages.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"

@interface EDCoreDataUtility (Pages)

// pages
+ (NSArray *)getAllPages:(NSManagedObjectContext *)context;
+ (NSMutableArray *)getAllSelectedPages:(NSManagedObjectContext *)context;
+ (NSArray *)getUnselectedPagesWithPageNumberLessThan:(int)upperNumber greaterThanOrEqualTo:(int)lowerNumber context:(NSManagedObjectContext *)context;
+ (NSArray *)getUnselectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber context:(NSManagedObjectContext *)context;
+ (NSArray *)getUnselectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber lessThan:(int)upperNumber context:(NSManagedObjectContext *)context;
+ (NSArray *)getSelectedPagesWithPageNumberLessThan:(int)upperNumber greaterThanOrEqualTo:(int)lowerNumber context:(NSManagedObjectContext *)context;
+ (NSArray *)getSelectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber lessThan:(int)upperNumber context:(NSManagedObjectContext *)context;
+ (NSArray *)getPagesWithPageNumberGreaterThan:(int)beginPageNumber context:(NSManagedObjectContext *)context;
+ (NSArray *)getPagesWithPageNumberGreaterThanOrEqualTo:(int)beginPageNumber context:(NSManagedObjectContext *)context;
+ (NSArray *)getPagesWithPageNumberGreaterThanOrEqualTo:(int)beginPageNumber lessThan:(int)endPageNumber context:(NSManagedObjectContext *)context;
+ (void)deleteSelectedPages:(NSManagedObjectContext *)context;
+ (void)correctPageNumbersAfterDelete:(NSManagedObjectContext *)context;
+ (void)removePage:(EDPage *)page context:(NSManagedObjectContext *)context;
+ (void)updatePageNumbersStartingAt:(int)startPageNumber byDifference:(int)difference endNumber:(int)endPageNumber context:(NSManagedObjectContext *)context;
+ (EDPage *)getPage:(EDPage *)page context:(NSManagedObjectContext *)context;
+ (EDPage *)getCurrentPage:(NSManagedObjectContext *)context;
+ (EDPage *)getPageWithNumber:(int)pageNumber context:(NSManagedObjectContext *)context;
+ (void)setPageAsCurrent:(EDPage *)page context:(NSManagedObjectContext *)context;
+ (EDPage *)getLastSelectedPage:(NSManagedObjectContext *)context;
+ (void)insertPages:(NSArray *)pages atPosition:(int)insertPosition pagesToUpdate:(NSArray *)pagesToUpdate context:(NSManagedObjectContext *)context;
+ (void)selectAllPages:(NSManagedObjectContext *)context;
+ (void)deselectAllPages:(NSManagedObjectContext *)context;
+ (EDPage *)getLastPage:(NSManagedObjectContext *)context;
+ (EDPage *)getFirstPage:(NSManagedObjectContext *)context;
@end
