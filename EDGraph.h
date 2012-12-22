//
//  EDGraph.h
//  GraphPouch
//
//  Created by PATRICK LEE on 12/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EDElement.h"

@class EDEquation, EDPage, EDPoint;

@interface EDGraph : EDElement

@property (nonatomic, retain) NSNumber * hasCoordinateAxes;
@property (nonatomic, retain) NSNumber * hasGridLines;
@property (nonatomic, retain) NSNumber * hasLabels;
@property (nonatomic, retain) NSNumber * hasTickMarks;
@property (nonatomic, retain) NSNumber * maxValueX;
@property (nonatomic, retain) NSNumber * maxValueY;
@property (nonatomic, retain) NSNumber * minValueX;
@property (nonatomic, retain) NSNumber * minValueY;
@property (nonatomic, retain) NSSet *equations;
@property (nonatomic, retain) EDPage *page;
@property (nonatomic, retain) NSSet *points;
@end

@interface EDGraph (CoreDataGeneratedAccessors)

- (void)addEquationsObject:(EDEquation *)value;
- (void)removeEquationsObject:(EDEquation *)value;
- (void)addEquations:(NSSet *)values;
- (void)removeEquations:(NSSet *)values;

- (void)addPointsObject:(EDPoint *)value;
- (void)removePointsObject:(EDPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end
