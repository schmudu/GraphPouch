//
//  EDConstants.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//
FOUNDATION_EXPORT int const GRAPH_INIT_TICK_MARKS;
FOUNDATION_EXPORT int const GRAPH_INIT_HAS_GRID_LINES;

#import <Foundation/Foundation.h>

@interface EDConstants : NSObject
// entity name
extern NSString *const EDEntityNameGraph;

// worksheet
extern NSString *const EDEventWorksheetClicked;
extern NSString *const EDEventMouseDown;
extern NSString *const EDEventUnselectedGraphClickedWithoutModifier;

// attributes
extern NSString *const EDWorksheetAttributeEquation;
extern NSString *const EDWorksheetAttributeGridLines;
extern NSString *const EDWorksheetAttributeSelected;
extern NSString *const EDWorksheetAttributeTickMarks;
extern NSString *const EDWorksheetAttributeLocationX;
extern NSString *const EDWorksheetAttributeLocationY;

@end
