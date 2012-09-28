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
// preferences
extern NSString *const EDPreferenceSnapToGuides;
extern NSString *const EDPreferencePropertyPanel;

// entity name
extern NSString *const EDEntityNameGraph;

// worksheet events
extern NSString *const EDEventWorksheetClicked;
extern NSString *const EDEventMouseDown;
extern NSString *const EDEventMouseDragged;
extern NSString *const EDEventMouseUp;
extern NSString *const EDEventUnselectedGraphClickedWithoutModifier;
extern NSString *const EDEventDeleteKeyPressedWithoutModifiers;
extern NSString *const EDEventWorksheetElementSelected;
extern NSString *const EDEventWorksheetElementDeselected;
extern NSString *const EDEventKey;

// menu
extern NSString *const EDEventMenuAlignTop;

// guides
extern NSString *const EDKeyGuideVertical;
extern NSString *const EDKeyGuideHorizontal;
extern NSString *const EDKeySnapOffset;
extern NSString *const EDKeyClosestGuide;
extern NSString *const EDKeyGuideDiff;
extern NSString *const EDKeyDiff;
extern NSString *const EDKeyValue;
extern float const EDGuideThreshold;
extern float const EDGuideWidth;
extern float const EDGuideShowThreshold;

// attributes
extern NSString *const EDGraphAttributeEquation;
extern NSString *const EDGraphAttributeGrideLines;
extern NSString *const EDElementAttributeSelected;
extern NSString *const EDGraphAttributeTickMarks;
extern NSString *const EDElementAttributeLocationX;
extern NSString *const EDElementAttributeLocationY;
extern NSString *const EDElementAttributeWidth;
extern NSString *const EDElementAttributeHeight;

// graphs
extern float const EDGraphDefaultHeight;
extern float const EDGraphDefaultWidth;

// keyboard mapping
extern int const        EDKeycodeDelete;
extern int const        EDKeyModifierNone;

// transform
extern float const EDTransformPointLength;
extern NSString *const EDEventTransformPointDragged;
extern NSString *const EDEventTransformRectChanged;
extern NSString *const EDEventTransformMouseUp;
extern NSString *const EDEventTransformMouseDown;
extern NSString *const EDKeyWidth;
extern NSString *const EDKeyHeight;
extern NSString *const EDKeyLocationY;
extern NSString *const EDKeyLocationX;
extern NSString *const EDKeyTransformDragPointX;
extern NSString *const EDKeyTransformDragPointY;
extern NSString *const EDTransformCornerUpperLeft;
extern NSString *const EDTransformCornerUpperRight;
extern NSString *const EDTransformCornerBottomLeft;
extern NSString *const EDTransformCornerBottomRight;
@end