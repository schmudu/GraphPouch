//
//  NSManagedObject+EasyFetching.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/5/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (EasyFetching)

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)getAllObjects;
+ (NSArray *)getAllObjectsOrderedByPageNumber;
+ (NSArray *)getAllSelectedObjects;
+ (NSArray *)getAllUnselectedObjects;
+ (NSArray *)getAllUnselectedObjectsOrderedByPageNumber;
+ (NSManagedObject *)getCurrentPage;
+ (NSArray *)getAllSelectedObjectsOrderedByPageNumber;
+ (NSManagedObjectContext *)getContext;
+ (void)printAll;

@end
