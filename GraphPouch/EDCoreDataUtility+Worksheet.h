//
//  EDCoreDataUtility+Worksheet.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/12/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"

@interface EDCoreDataUtility (Worksheet)

+ (NSMutableArray *)getAllWorksheetElements:(NSManagedObjectContext *)context;
+ (NSMutableArray *)getAllSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (NSMutableDictionary *)getAllTypesOfSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (void)clearSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (void)selectAllWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context;
+ (void)selectNextWorksheetElementOnCurrentPage:(NSManagedObjectContext *)context;
+ (void)selectPreviousWorksheetElementOnCurrentPage:(NSManagedObjectContext *)context;
+ (void)deleteSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (void)insertWorksheetElements:(NSArray *)elements context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)copySelectedWorksheetElements:(NSManagedObjectContext *)context;
    
@end
