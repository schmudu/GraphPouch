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
// create context
+ (NSMutableDictionary *)createContext:(NSManagedObjectContext *)startContext;
    
// objects
+ (NSManagedObject *)getObject:(NSManagedObject *)object context:(NSManagedObjectContext *)context;
    
// selection
//+ (NSArray *)getAllGraphs:(NSManagedObjectContext *)context;
// save
//+ (void)save:(NSManagedObjectContext *)context;
+ (BOOL)save:(NSManagedObjectContext *)context;
@end
