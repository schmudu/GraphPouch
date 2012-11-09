//
//  EDCoreDataUtility+Points.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/8/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDPoint.h"

@interface EDCoreDataUtility (Points)

// points
- (NSArray *)getAllCommonPointsforSelectedGraphs;
- (NSArray *)getOneCommonPointFromSelectedGraphsMatchingPoint:(EDPoint *)matchPoint;
- (void)setAllCommonPointsforSelectedGraphs:(EDPoint *)pointToChange attribute:(NSDictionary *)attributes;
- (void)removeCommonPointsforSelectedGraphsMatchingPoints:(NSArray *)pointsToRemove;
@end
