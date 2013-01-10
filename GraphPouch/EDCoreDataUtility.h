//
//  EDCoreDataUtility.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDPage.h"
#import "EDPoint.h"

@interface EDCoreDataUtility : NSObject{
}

// objects
+ (NSMutableArray *)getAllWorksheetElements:(NSManagedObjectContext *)context;
+ (NSManagedObject *)getObject:(NSManagedObject *)object context:(NSManagedObjectContext *)context;
    
// selection
//+ (NSArray *)getAllGraphs:(NSManagedObjectContext *)context;
+ (NSMutableArray *)getAllSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (NSMutableDictionary *)getAllTypesOfSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (void)clearSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (void)deleteSelectedWorksheetElements:(NSManagedObjectContext *)context;
+ (void)insertWorksheetElements:(NSArray *)elements context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)copySelectedWorksheetElements:(NSManagedObjectContext *)context;
    
// save
+ (void)save:(NSManagedObjectContext *)context;
@end
