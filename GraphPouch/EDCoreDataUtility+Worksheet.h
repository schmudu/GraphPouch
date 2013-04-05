//
//  EDCoreDataUtility+Worksheet.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/12/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDConstants.h"
#import "EDElement.h"

@interface EDCoreDataUtility (Worksheet)

+ (NSMutableArray *)copySelectedWorksheetElementsFromContext:(NSManagedObjectContext *)context toContext:(NSManagedObjectContext *)copyContext;
+ (void)deleteSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (void)deleteWorksheetElement:(EDElement *)element context:(NSManagedObjectContext *)context;
+ (void)deselectAllSelectedWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context;
+ (void)deselectAllSelectedWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context selectElement:(EDElement *)element;
+ (NSMutableArray *)getAllSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (NSMutableArray *)getAllWorksheetElementsOnPage:(EDPage *)currentPage context:(NSManagedObjectContext *)context;
+ (NSMutableDictionary *)getAllTypesOfSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (NSArray *)insertWorksheetElements:(NSArray *)elements intoContext:(NSManagedObjectContext *)context;
+ (void)moveSelectedWorksheetElements:(EDDirection)direction multiplyModifier:(BOOL)modifier context:(NSManagedObjectContext *)context;
+ (void)selectAllWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context;
+ (void)selectNextWorksheetElementOnCurrentPage:(NSManagedObjectContext *)context;
+ (void)selectPreviousWorksheetElementOnCurrentPage:(NSManagedObjectContext *)context;
+ (void)selectElementsInRect:(NSRect)rect context:(NSManagedObjectContext *)context;

@end
