//
//  NSManagedObject+EasyFetching.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/5/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "EDPage.h"

@interface NSManagedObject (EasyFetching)

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)getAllObjects:(NSManagedObjectContext *)context;
+ (NSArray *)getAllObjectsOnPage:(EDPage *)page context:(NSManagedObjectContext *)context;
+ (NSArray *)getAllObjectsOrderedByPageNumber:(NSManagedObjectContext *)context;
+ (NSArray *)getAllSelectedObjects:(NSManagedObjectContext *)context;
+ (NSArray *)getAllUnselectedObjects:(NSManagedObjectContext *)context;
+ (NSArray *)getAllUnselectedObjectsOrderedByPageNumber:(NSManagedObjectContext *)context;
+ (NSManagedObject *)getCurrentPage:(NSManagedObjectContext *)context;
+ (NSArray *)getAllSelectedObjectsOrderedByPageNumber:(NSManagedObjectContext *)context;
+ (void)printAll:(NSManagedObjectContext *)context;

@end
