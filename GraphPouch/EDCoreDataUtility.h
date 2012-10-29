//
//  EDCoreDataUtility.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDPage.h"

@interface EDCoreDataUtility : NSObject{
@private
    NSManagedObjectContext *_context;
}

+ (EDCoreDataUtility *)sharedCoreDataUtility;
- (void)setContext:(NSManagedObjectContext *)moc;
- (void)save;
- (NSManagedObjectContext *)context;
// objects
- (NSMutableArray *)getAllObjects;

// selection
- (NSMutableArray *)getAllSelectedObjects;
- (NSMutableDictionary *)getAllTypesOfSelectedObjects;
- (void)clearSelectedElements;
- (void)deleteSelectedElements;

// graphs
- (NSArray *)getAllGraphs;
@end
