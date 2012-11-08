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
@private
    NSManagedObjectContext *_context;
}

+ (EDCoreDataUtility *)sharedCoreDataUtility;
- (void)setContext:(NSManagedObjectContext *)moc;
- (void)save;
- (NSManagedObjectContext *)context;

// objects
- (NSMutableArray *)getAllWorksheetElements;
- (NSManagedObject *)getObject:(NSManagedObject *)object;
    
// selection
- (NSMutableArray *)getAllSelectedWorksheetElements;
- (NSMutableDictionary *)getAllTypesOfSelectedWorksheetElements;
- (void)clearSelectedWorksheetElements;
- (void)deleteSelectedWorksheetElements;

// graphs
- (NSArray *)getAllGraphs;

@end
