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
+ (NSArray *)findAllObjects;
+ (NSArray *)findAllObjectsOrderedByPageNumber;
+ (NSArray *)findAllSelectedObjects;
+ (NSArray *)findAllSelectedObjectsOrderedByPageNumber;
+ (NSManagedObjectContext *)getContext;

@end
