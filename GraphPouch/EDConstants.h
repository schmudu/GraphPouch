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
// General
extern NSString *const EDKey;
extern NSString *const EDValue;

// UTI
extern NSString *const EDUTIPage;
extern NSString *const EDUTIGraph;

// num
extern float const EDNumberMax;

// preferences
extern NSString *const EDPreferenceSnapToGuides;
extern NSString *const EDPreferencePropertyPanel;

// entity name
extern NSString *const EDEntityNameGraph;
extern NSString *const EDEntityNamePage;
extern NSString *const EDEntityNamePoint;

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
extern NSString *const EDEventShortcutNewPage;
extern NSString *const EDEventShortcutCopy;
extern NSString *const EDEventShortcutCut;
extern NSString *const EDEventShortcutPaste;

// guides
extern NSString *const EDKeyGuideVertical;
extern NSString *const EDKeyGuideHorizontal;
extern NSString *const EDKeySnapOffset;
extern NSString *const EDKeyClosestGuide;
extern NSString *const EDKeyGuideDiff;
extern NSString *const EDKeyDiff;
extern NSString *const EDKeyValue;
extern NSString *const EDKeyDidSnapX;
extern NSString *const EDKeyDidSnapY;
extern NSString *const EDKeySnapInfo;
extern NSString *const EDKeySnapDistanceX;
extern NSString *const EDKeySnapDistanceY;
extern NSString *const EDKeySnapBackDistanceY;
extern NSString *const EDKeySnapBackDistanceX;
extern NSString *const EDKeyDidSnapBack;
extern NSString *const EDKeyWorksheetElement;
extern float const EDGuideThreshold;
extern float const EDGuideWidth;
extern float const EDGuideShowThreshold;

// attributes
extern NSString *const EDGraphAttributeLabels;
extern NSString *const EDGraphAttributeEquation;
extern NSString *const EDGraphAttributeGridLines;
extern NSString *const EDElementAttributeSelected;
extern NSString *const EDGraphAttributeTickMarks;
extern NSString *const EDGraphAttributeCoordinateAxes;
extern NSString *const EDGraphAttributePoints;
extern NSString *const EDElementAttributeLocationX;
extern NSString *const EDElementAttributeLocationY;
extern NSString *const EDElementAttributeWidth;
extern NSString *const EDElementAttributeHeight;

// graphs
extern float const EDGraphDefaultHeight;
extern float const EDGraphDefaultWidth;
extern float const EDGraphDefaultCoordinateLineWidth;
extern NSString *const EDGraphSelectedBackgroundColor;
extern float const EDGraphSelectedBackgroundAlpha;
extern float const EDCoordinateArrowWidth;
extern float const EDCoordinateArrowLength;
extern float const EDGridDistanceMinimumThreshold;
extern int const EDGridMaximum;
extern float const EDGridIncrementalMaximum;
extern float const EDGridIncrementalMinimum;
extern NSString *const EDGridColor;
extern float const EDGridAlpha;
extern NSString *const EDKeyDistanceIncrement;
extern NSString *const EDKeyGridFactor;
extern NSString *const EDKeyGridLinesCount;
extern float const EDGraphTickLength;
extern float const EDGraphVerticalLabelHorizontalOffset;
extern float const EDGraphVerticalLabelVerticalOffset;
extern float const EDGraphHorizontalLabelHorizontalOffset;
extern float const EDGraphHorizontalLabelVerticalOffset;
extern float const EDGraphHorizontalLabelHorizontalNegativeOffset;
extern float const EDGraphXLabelHorizontalOffset;
extern float const EDGraphYLabelVerticalOffset;
extern float const EDGraphPointDiameter;

// graph points
extern NSString *const EDGraphPointAttributeVisible;
extern NSString *const EDGraphPointAttributeShowLabel;

// window
extern NSString *const EDEventWindowDidResize;
extern NSString *const EDEventWindowWillClose;

// pages
extern NSString *const EDEventPagesViewClicked;
//extern NSString *const EDEventPageViewDragged;
extern NSString *const EDEventPagesDeletePressed;
extern NSString *const EDEventPageViewStartDrag;
extern NSString *const EDEventPageViewsFinishedDrag;
extern NSString *const EDKeySelectedPageFirst;
extern NSString *const EDKeySelectedPageLast;
extern NSString *const EDKeyPageViewDragPoint;
extern NSString *const EDKeyPageViewData;
extern NSString *const EDKeyPagesViewDraggedViews;
extern NSString *const EDKeyPagesViewHighlightedDragSection;
extern NSString *const EDPageViewAttributeHighlighted;
extern NSString *const EDPageViewAttributeDataObject;
extern float const EDPageViewOffsetY;
extern float const EDPageViewIncrementPosY;
extern float const EDPageViewPosX;
extern float const EDPageImageViewWidth;
extern float const EDPageImageViewHeight;
extern float const EDPageViewDragPosX;
extern float const EDPageViewDragOffsetY;
extern float const EDPageViewDragWidth;
extern float const EDPageViewDragLength;

// page
extern NSString *const EDPageAttributePageNumber;
extern NSString *const EDPageAttributeSelected;
extern NSString *const EDPageAttributeCurrent;
extern NSString *const EDPageAttributeGraphs;
extern NSString *const EDGraphAttributePage;
extern NSString *const EDEventPageClickedWithoutModifier;
extern NSString *const EDEventPageViewMouseDown;

// keyboard mapping
extern int const        EDKeycodeDelete;
extern int const        EDKeycodeCopy;
extern int const        EDKeycodeCut;
extern int const        EDKeycodePaste;
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