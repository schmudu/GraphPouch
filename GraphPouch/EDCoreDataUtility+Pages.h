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
- (NSArray *)getAllPages;
- (NSMutableArray *)getAllSelectedPages;
- (NSArray *)getUnselectedPagesWithPageNumberLessThan:(int)upperNumber greaterThanOrEqualTo:(int)lowerNumber;
- (NSArray *)getUnselectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber;
- (NSArray *)getUnselectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber lessThan:(int)upperNumber;
- (NSArray *)getSelectedPagesWithPageNumberLessThan:(int)upperNumber greaterThanOrEqualTo:(int)lowerNumber;
- (NSArray *)getSelectedPagesWithPageNumberGreaterThanOrEqualTo:(int)lowerNumber lessThan:(int)upperNumber;
- (NSArray *)getPagesWithPageNumberGreaterThan:(int)beginPageNumber;
- (NSArray *)getPagesWithPageNumberGreaterThanOrEqualTo:(int)beginPageNumber;
- (NSArray *)getPagesWithPageNumberGreaterThanOrEqualTo:(int)beginPageNumber lessThan:(int)endPageNumber;
- (void)deleteSelectedPages;
- (void)correctPageNumbersAfterDelete;
- (void)removePage:(EDPage *)page;
- (void)updatePageNumbersStartingAt:(int)startPageNumber byDifference:(int)difference endNumber:(int)endPageNumber;
- (EDPage *)getPage:(EDPage *)page;
- (EDPage *)getCurrentPage;
- (void)setPageAsCurrent:(EDPage *)page;
- (EDPage *)getLastSelectedPage;
@end
