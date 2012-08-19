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

// worksheet events
extern NSString *const EDEventWorksheetClicked;
extern NSString *const EDEventMouseDown;
extern NSString *const EDEventMouseDragged;
extern NSString *const EDEventMouseUp;
extern NSString *const EDEventUnselectedGraphClickedWithoutModifier;
extern NSString *const EDEventKey;

// attributes
extern NSString *const EDGraphAttributeEquation;
extern NSString *const EDGraphAttributeGrideLines;
extern NSString *const EDElementAttributeSelected;
extern NSString *const EDGraphAttributeTickMarks;
extern NSString *const EDElementAttributeLocationX;
extern NSString *const EDElementAttributeLocationY;

@end
