//
//  EDGraph.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EDElement.h"

@class EDPage;
@class EDPoint;

@interface EDGraph : EDElement <NSCoding>

@property (nonatomic, retain) NSString * equation;
@property BOOL hasCoordinateAxes;
@property BOOL hasGridLines;
@property BOOL hasTickMarks;
@property (nonatomic, retain) EDPage *page;
@property (nonatomic, retain) NSSet *points;
@end

@interface EDGraph (CoreDataGeneratedAccessors)
- (void)addPointsObject:(EDPoint *)value;
- (void)removePointsObject:(EDPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;
@end
