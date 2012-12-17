//
//  EDCoreDataUtility+Equations.h
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDEquation.h"

@interface EDCoreDataUtility (Equations)

+ (NSArray *)getCommonEquationsforSelectedGraphs:(NSManagedObjectContext *)context;
+ (NSArray *)getOneCommonEquationFromSelectedGraphsMatchingEquation:(EDEquation *)matchEquation context:(NSManagedObjectContext *)context;
+ (void)setAllCommonEquationsforSelectedGraphs:(EDEquation *)equationToChange attribute:(NSDictionary *)attributes context:(NSManagedObjectContext *)context;
+ (void)removeCommonEquationsforSelectedGraphsMatchingEquations:(NSArray *)equationsToRemove context:(NSManagedObjectContext *)context;
@end
