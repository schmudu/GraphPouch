//
//  EDCoreDataUtility+Worksheet.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/12/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDConstants.h"

@interface EDCoreDataUtility (Worksheet)

//+ (NSMutableArray *)copySelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (NSMutableArray *)copySelectedWorksheetElementsFromContext:(NSManagedObjectContext *)context toContext:(NSManagedObjectContext *)copyContext;
+ (void)deleteSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (void)deselectAllSelectedWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context;
+ (NSMutableArray *)getAllSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (NSMutableDictionary *)getAllTypesOfSelectedWorksheetElements:(NSManagedObjectContext *)context;
//+ (void)insertWorksheetElements:(NSArray *)elements context:(NSManagedObjectContext *)context;
+ (void)insertWorksheetElements:(NSArray *)elements intoContext:(NSManagedObjectContext *)context;
+ (void)moveSelectedWorksheetElements:(EDDirection)direction multiplyModifier:(BOOL)modifier context:(NSManagedObjectContext *)context;
+ (void)selectAllWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context;
+ (void)selectNextWorksheetElementOnCurrentPage:(NSManagedObjectContext *)context;
+ (void)selectPreviousWorksheetElementOnCurrentPage:(NSManagedObjectContext *)context;

@end
