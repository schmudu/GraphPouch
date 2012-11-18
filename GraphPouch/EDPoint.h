//
//  EDPoint.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EDGraph;

@interface EDPoint : NSManagedObject <NSCoding, NSCopying>

@property float locationX;
@property BOOL isVisible;
@property BOOL showLabel;
@property BOOL matchesHaveSameVisibility;
@property BOOL matchesHaveSameLabel;
@property float locationY;
@property (nonatomic, retain) EDGraph *graph;

- (BOOL)matchesPoint:(EDPoint *)otherPoint;
- (BOOL)matchesPointByCoordinate:(EDPoint *)otherPoint;
- (void)copyAttributes:(EDPoint *)otherPoint;
@end
