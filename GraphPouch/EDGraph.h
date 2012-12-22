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
@class EDEquation;

@interface EDGraph : EDElement <NSCoding>

@property BOOL hasCoordinateAxes;
@property BOOL hasGridLines;
@property BOOL hasTickMarks;
@property BOOL hasLabels;
@property (nonatomic, retain) NSNumber *minValueX;
@property (nonatomic, retain) NSNumber *minValueY;
@property (nonatomic, retain) NSNumber *maxValueX;
@property (nonatomic, retain) NSNumber *maxValueY;
@property (nonatomic, retain) EDPage *page;
@property (nonatomic, retain) NSSet *points;
@property (nonatomic, retain) NSSet *equations;
@end

@interface EDGraph (CoreDataGeneratedAccessors)
// points
- (void)addPointsObject:(EDPoint *)value;
- (void)removePointsObject:(EDPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

// equations
- (void)addEquationsObject:(EDEquation *)value;
- (void)removeEquationsObject:(EDEquation *)value;
- (void)addEquations:(NSSet *)values;
- (void)removeEquations:(NSSet *)values;
@end
