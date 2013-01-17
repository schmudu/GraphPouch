//
//  EDCoreDataUtility+Graphs.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/16/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDPage.h"

@interface EDCoreDataUtility (Graphs)

+ (NSArray *)getGraphsForPage:(EDPage *)page context:(NSManagedObjectContext *)context;
@end
