//
//  EDCoreDataUtility+Lines.h
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"

@interface EDCoreDataUtility (Lines)

+ (NSArray *)getLinesForPage:(EDPage *)page context:(NSManagedObjectContext *)context;
@end
