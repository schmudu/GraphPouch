//
//  EDConstants.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
int const GRAPH_INIT_TICK_MARKS         = FALSE; 
int const GRAPH_INIT_HAS_GRID_LINES     = FALSE; 

@implementation EDConstants
// Context
NSString * const EDKeyContextChild                              = @"EDKeyContextChild";
NSString * const EDKeyContextRoot                               = @"EDKeyContextRoot";

// UTI
NSString * const EDUTIPage                                      = @"com.edcodia.graphpouch.page";
NSString * const EDUTIPageView                                  = @"com.edcodia.graphpouch.pageview";
NSString * const EDUTIGraph                                     = @"com.edcodia.graphpouch.graph";
NSString * const EDUTIGraphView                                 = @"com.edcodia.graphpouch.graphView";
NSString * const EDUTIToken                                     = @"com.edcodia.graphpouch.token";
NSString * const EDUTIEquation                                  = @"com.edcodia.graphpouch.equation";

// General
NSString * const EDKey                                          = @"EDKey";
NSString * const EDValue                                        = @"EDValue";
NSString * const EDSelectedViewColor                            = @"3E8DD3";
float const EDSelectedViewStrokeWidth                            = 2.0;

// numbers
float const EDNumberMax                                         = 9999999;

// preferences
NSString * const EDPreferenceSnapToGuides                       = @"EDPreferenceSnapToGuides";
NSString * const EDPreferencePropertyPanel                      = @"EDPreferencePropertyPanel";

// entity names
NSString * const EDEntityNameGraph                              = @"EDGraph";
NSString * const EDEntityNamePage                               = @"EDPage";
NSString * const EDEntityNamePoint                              = @"EDPoint";
NSString * const EDEntityNameEquation                           = @"EDEquation";
NSString * const EDEntityNameToken                              = @"EDToken";

// worksheet events
NSString * const EDEventWorksheetClicked                        = @"EDEventWorksheetClicked";
NSString * const EDEventMouseDown                               = @"EDEventMouseDown";
NSString * const EDEventMouseDragged                            = @"EDEventMouseDragged";
NSString * const EDEventMouseUp                                 = @"EDEventMouseUp";
NSString * const EDEventUnselectedGraphClickedWithoutModifier   = @"EDEventUnselectedGraphClickedWithoutModifier";
NSString * const EDEventDeleteKeyPressedWithoutModifiers        = @"EDEventDeleteKeyPressedWithoutModifiers";
NSString * const EDEventWorksheetElementSelected                = @"EDEventWorksheetElementSelected";
NSString * const EDEventWorksheetElementDeselected              = @"EDEventWorksheetElementDeselected";
NSString * const EDEventKey                                     = @"EDEvent";

// menu
NSString * const EDEventMenuAlignTop                            = @"EDEventMenuAlignTop";
NSString * const EDEventShortcutNewPage                         = @"EDEventShortcutNewPage";
NSString * const EDEventShortcutCopy                            = @"EDEventShortcutCopy";
NSString * const EDEventShortcutCut                             = @"EDEventShortcutCut";
NSString * const EDEventShortcutPaste                           = @"EDEventShortcutPaste";
NSString * const EDEventShortcutSave                            = @"EDEventShortcutSave";
NSString * const EDEventShortcutGraph                           = @"EDEventShortcutGraph";
NSString * const EDEventShortcutPage                            = @"EDEventShortcutPage";
NSString * const EDEventShortcutSelectAll                       = @"EDEventShortcutSelectAll";
NSString * const EDEventShortcutDeselectAll                     = @"EDEventShortcutDeselectAll";

// guides
NSString * const EDKeyGuideVertical                             = @"EDKeyGuideVertical";
NSString * const EDKeyGuideHorizontal                           = @"EDKeyGuideHorizontal";
NSString * const EDKeySnapOffset                                = @"EDKeySnapOffset";
NSString * const EDKeyClosestGuide                              = @"EDKeyClosestGuide";
NSString * const EDKeyGuideDiff                                 = @"EDKeyGuideDiff";
NSString * const EDKeyDiff                                      = @"EDKeyDiff";
NSString * const EDKeyValue                                     = @"EDKeyValue";
NSString * const EDKeyDidSnapX                                  = @"EDKeyDidSnapX";
NSString * const EDKeyDidSnapY                                  = @"EDKeyDidSnapY";
NSString * const EDKeySnapInfo                                  = @"EDKeySnapInfo";
NSString * const EDKeySnapDistanceX                             = @"EDKeySnapDistanceX";
NSString * const EDKeySnapDistanceY                             = @"EDKeySnapDistanceY";
NSString * const EDKeySnapBackDistanceY                         = @"EDKeySnapBackDistanceY";
NSString * const EDKeySnapBackDistanceX                         = @"EDKeySnapBackDistanceX";
NSString * const EDKeyDidSnapBack                               = @"EDKeyDidSnapBack";
NSString * const EDKeyWorksheetElement                          = @"EDKeyWorksheetElement";
float const EDGuideThreshold                                    = 2.0;
float const EDGuideWidth                                        = 3.0;
float const EDGuideShowThreshold                                = 10.0;  // diff must be less then this to show guide

// element attributes
NSString * const EDElementAttributeSelected                     = @"selected";
NSString * const EDElementAttributeLocationX                    = @"locationX";
NSString * const EDElementAttributeLocationY                    = @"locationY";
NSString * const EDElementAttributeWidth                        = @"elementWidth";
NSString * const EDElementAttributeHeight                       = @"elementHeight";

// graph attributes
NSString * const EDGraphAttributeLabels                         = @"hasLabels";
NSString * const EDGraphAttributeTickMarks                      = @"hasTickMarks";
NSString * const EDGraphAttributeCoordinateAxes                 = @"hasCoordinateAxes";
NSString * const EDGraphAttributeEquation                       = @"equation";
NSString * const EDGraphAttributeGridLines                      = @"hasGridLines";
NSString * const EDGraphAttributePoints                         = @"points";
NSString * const EDGraphAttributeEquations                      = @"equations";
NSString * const EDGraphAttributeMinValueX                      = @"minValueX";
NSString * const EDGraphAttributeMinValueY                      = @"minValueY";
NSString * const EDGraphAttributeMaxValueX                      = @"maxValueX";
NSString * const EDGraphAttributeMaxValueY                      = @"maxValueY";
NSString * const EDGraphSelectedBackgroundColor                 = @"aaaaff";
float const EDGraphSelectedBackgroundAlpha                      = 0.2;
float const EDGraphDefaultHeight                                = 30.0;
float const EDGraphDefaultWidth                                 = 30.0;
float const EDGraphDefaultCoordinateLineWidth                   = 1.5;
float const EDCoordinateArrowWidth                              = 5.0;
float const EDCoordinateArrowLength                             = 10.0;
float const EDGridDistanceMinimumThreshold                      = 20.0;
int const EDGridMaximum                                         = 10;
float const EDGridIncrementalMaximum                            = 70;
float const EDGridIncrementalMinimum                            = 20;
NSString * const EDGridColor                                    = @"bbbbbb";
float const EDGridAlpha                                         = 0.8;
NSString * const EDKeyGridFactor                                = @"EDKeyGridFactor";
NSString * const EDKeyDistanceIncrement                         = @"EDKeyDistanceIncrement";
NSString * const EDKeyGridLinesCount                            = @"EDKeyGridLinesCount";
float const EDGraphTickLength                                   = 4;
float const EDGraphVerticalLabelHorizontalOffset                = 6.0;
float const EDGraphVerticalLabelVerticalOffset                  = 9.0;
float const EDGraphHorizontalLabelHorizontalOffset              = -5;
float const EDGraphHorizontalLabelVerticalOffset                = 5;
float const EDGraphHorizontalLabelHorizontalNegativeOffset      = 6;
float const EDGraphXLabelHorizontalOffset                       = -6;
float const EDGraphYLabelVerticalOffset                         = 2;
float const EDGraphPointDiameter                                = 10;
NSString * const EDKeyRatioHorizontal                           = @"EDKeyRatioHorizontal";
NSString * const EDKeyRatioVertical                             = @"EDKeyRatioVertical";
float const EDGraphMargin                                       = 20;
float const EDGraphInnerMargin                                  = 20;
NSString * const EDKeyOriginPositionHorizontal                  = @"EDKeyOriginPositionHorizontal";
NSString * const EDKeyOriginPositionVertical                    = @"EDKeyOriginPositionVertical";
NSString * const EDKeyNumberGridLinesPositive                   = @"EDKeyNumberGridLinesPositive";
NSString * const EDKeyNumberGridLinesNegative                   = @"EDKeyNumberGridLinesNegative";
float const EDGraphEquationIncrement                            = .25;

// graph points
NSString * const EDGraphPointAttributeVisible                   = @"isVisible";
NSString * const EDGraphPointAttributeShowLabel                 = @"showLabel";
float const EDGraphPointLabelHeight                             = 20;
float const EDGraphPointLabelWidth                              = 60;
float const EDGraphPointLabelVerticalOffset                     = 1;
float const EDGraphPointLabelHorizontalOffset                   = 8;
float const EDGraphDependentVariableIncrement                   = 5.0;        // the higher the number the more accurate the graphs, but worse performance

// window
NSString * const EDEventWindowDidResize                         = @"EDEventWindowDidResize";
NSString * const EDEventWindowWillClose                         = @"EDEventWindowWillClose";

// pages view
NSString * const EDEventPagesViewClicked                        = @"EDEventPagesViewClicked";
NSString * const EDEventPagesDeletePressed                      = @"EDEventPagesDeletePressed";
//NSString * const EDEventPageViewDragged                         = @"EDEventPageViewDragged";
NSString * const EDEventPageViewStartDrag                       = @"EDEventPageViewStartDrag";
NSString * const EDEventPageViewsFinishedDrag                   = @"EDEventPageViewsFinishedDrag";
NSString * const EDKeySelectedPageFirst                         = @"EDKeySelectedPageFirst";
NSString * const EDKeySelectedPageLast                          = @"EDKeySelectedPageLast";
NSString * const EDKeyPageViewDragPoint                         = @"EDKeyPageViewDragPoint";
NSString * const EDKeyPageViewData                              = @"EDKeyPageViewData";
NSString * const EDKeyPagesViewDraggedViews                     = @"EDKeyPagesViewDraggedViews";
NSString * const EDKeyPagesViewHighlightedDragSection           = @"EDKeyPagesViewHighlightedDragSection";
NSString * const EDPageViewAttributeHighlighted                 = @"EDPageViewAttributeHighlighted";
NSString * const EDPageViewAttributeDataObject                  = @"EDPageViewAttributeDataObject";
NSString * const EDPageViewSelectionColor                       = @"000000";
float const EDPageViewSelectionAlpha                            = 0.2;
float const EDPageViewSelectionWidth                            = 70;
float const EDPageViewSelectionHeight                           = 90;
float const EDPageViewOffsetY                                   = 30;
float const EDPageViewIncrementPosY                             = 120;
float const EDPageViewPosX                                      = 0;
float const EDPageImageViewWidth                                = 60;
float const EDPageImageViewHeight                               = 80;
float const EDPageViewDragPosX                                  = 30;
float const EDPageViewDragOffsetY                               = -5;
float const EDPageViewDragWidth                                 = 80;
float const EDPageViewDragLength                                = 10;

// page view
NSString * const EDPageAttributePageNumber                      = @"pageNumber";
NSString * const EDPageAttributeSelected                        = @"selected";
NSString * const EDPageAttributeCurrent                         = @"currentPage";
NSString * const EDPageAttributeGraphs                          = @"graphs";
NSString * const EDGraphAttributePage                           = @"page";
NSString * const EDEventPageClickedWithoutModifier              = @"EDEventPageClickedWithoutModifier";
NSString * const EDEventPageViewMouseDown                       = @"EDEventPageViewMouseDown";

// keyboard

int const EDKeycodeSave                                         = 1;
int const EDKeycodeQuit                                         = 12;
int const EDKeycodeDelete                                       = 51;
int const EDKeycodeCopy                                         = 8;
int const EDKeycodeCut                                          = 7;
int const EDKeycodePaste                                        = 9;
int const EDKeycodeGraph                                        = 9;
int const EDKeycodePage                                         = 9;
int const EDKeycodeAll                                          = 0;
int const EDKeycodeDeselect                                     = 2;
int const EDKeyModifierNone                                     = 256;

// transform
float const EDTransformPointLength                              = 10;
NSString * const EDEventTransformPointDragged                   = @"EDEventTransformPointDragged";
NSString * const EDEventTransformRectChanged                    = @"EDEventTransformRectChanged";
NSString * const EDEventTransformMouseUp                        = @"EDEventTransformMouseUp";
NSString * const EDEventTransformMouseDown                      = @"EDEventTransformMouseDown";
NSString * const EDKeyHeight                                    = @"EDKeyHeight";
NSString * const EDKeyWidth                                     = @"EDKeyWidth";
NSString * const EDKeyLocationX                                 = @"EDKeyLocationX";
NSString * const EDKeyLocationY                                 = @"EDKeyLocationY";
NSString * const EDKeyTransformDragPointX                       = @"EDKeyTransformDragPointX";
NSString * const EDKeyTransformDragPointY                       = @"EDKeyTransformDragPointY";
NSString * const EDTransformCornerUpperLeft                     = @"EDTransformCornerUpperLeft";
NSString * const EDTransformCornerUpperRight                    = @"EDTransformCornerUpperRight";
NSString * const EDTransformCornerBottomLeft                    = @"EDTransformCornerBottomLeft";
NSString * const EDTransformCornerBottomRight                   = @"EDTransformCornerBottomRight";

// equations
NSString * const EDEquationAttributeEquation                    = @"equation";
NSString * const EDEquationAttributeShowLabel                   = @"showLabel";
NSString * const EDEquationAttributeIsVisible                   = @"isVisible";
NSString * const EDEquationAttributeTokens                      = @"tokens";
NSString * const EDEventQuitDuringEquationSheet                 = @"EDEventQuitDuringEquationSheet";
int const EDEquationSheetIndexInvalid                           = -1;

// errors
NSString * const EDErrorDomain                                  = @"com.edcodia.graphpouch";
int const EDErrorTokenizer                                      = 1;

// tokenize
NSString * const EDKeyValidEquation                             = @"EDKeyValidEquation";
NSString * const EDKeyParsedTokens                              = @"EDKeyParsedTokens";
NSString * const EDKeyEquation                                  = @"EDKeyEquation";

NSString *const EDTokenAttributeIsValid                         = @"isValid";
NSString *const EDTokenAttributePrecedence                      = @"precedence";
NSString *const EDTokenAttributeValue                           = @"tokenValue";
NSString *const EDTokenAttributeType                            = @"type";
NSString *const EDTokenAttributeAssociation                     = @"association";
NSString *const EDTokenAttributeEquation                        = @"equation";



@end
