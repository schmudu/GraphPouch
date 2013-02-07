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
// Context
extern NSString *const EDKeyContextChild;
extern NSString *const EDKeyContextRoot;

// General
extern NSString *const EDKey;
extern NSString *const EDValue;
extern NSString *const EDSelectedViewColor;
extern float const EDSelectedViewStrokeWidth;

// UTI
extern NSString *const EDUTIPage;
extern NSString *const EDUTIPageView;
extern NSString *const EDUTIGraph;
extern NSString *const EDUTIGraphView;
extern NSString *const EDUTIToken;
extern NSString *const EDUTIEquation;
extern NSString *const EDUTILine;
extern NSString *const EDUTITextbox;

// num
extern float const EDNumberMax;

// preferences
extern NSString *const EDPreferenceSnapToGuides;
extern NSString *const EDPreferencePropertyPanel;

// panels
extern NSString *const EDKeyGraphLine;
extern NSString *const EDKeyGraphLineTextbox;
extern NSString *const EDKeyGraph;
extern NSString *const EDKeyGraphTextbox;
extern NSString *const EDKeyLine;
extern NSString *const EDKeyLineTextbox;
extern NSString *const EDKeyTextbox;

// panel events
extern NSString *const EDEventControlReceivedFocus;

// layout
extern float const EDMenuToolbarHeight;

// entity name
extern NSString *const EDEntityNameGraph;
extern NSString *const EDEntityNamePage;
extern NSString *const EDEntityNamePoint;
extern NSString *const EDEntityNameEquation;
extern NSString *const EDEntityNameToken;
extern NSString *const EDEntityNameLine;
extern NSString *const EDEntityNameTextbox;

// textfield
extern NSString *const EDTextboxAttributeTextValue;
extern NSString *const EDKeyEvent;

// line
extern NSString *const EDLineAttributeThickness;

// worksheet
extern float const EDWorksheetViewHeight;
extern float const EDWorksheetViewWidth;
extern float const EDWorksheetShadowSize;
extern NSString *const EDWorksheetShadowColor;

// worksheet events
extern NSString *const EDEventWorksheetClicked;
extern NSString *const EDEventMouseDoubleClick;
extern NSString *const EDEventMouseDown;
extern NSString *const EDEventMouseDragged;
extern NSString *const EDEventMouseUp;
extern NSString *const EDEventTabPressedWithoutModifiers;
extern NSString *const EDEventUnselectedElementClickedWithoutModifier;
extern NSString *const EDEventDeleteKeyPressedWithoutModifiers;
extern NSString *const EDEventBecomeFirstResponder;
extern NSString *const EDEventWorksheetElementSelected;
extern NSString *const EDEventWorksheetElementDeselected;
extern NSString *const EDEventWorksheetViewResignFirstResponder;
extern NSString *const EDEventKey;

// menu
extern NSString *const EDEventMenuAlignTop;
extern NSString *const EDEventShortcutNewPage;
extern NSString *const EDEventShortcutCopy;
extern NSString *const EDEventShortcutCut;
extern NSString *const EDEventShortcutPaste;
extern NSString *const EDEventShortcutSave;
extern NSString *const EDEventShortcutGraph;
extern NSString *const EDEventShortcutPage;
extern NSString *const EDEventShortcutSelectAll;
extern NSString *const EDEventShortcutDeselectAll;
extern float const EDMenuToolbarShadowWidth;


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
extern NSString *const EDGraphBorderColor;
extern float const EDPageViewGraphBorderLineWidth;
extern NSString *const EDGraphAttributeGridLines;
extern NSString *const EDElementAttributeSelected;
extern NSString *const EDGraphAttributeTickMarks;
extern NSString *const EDGraphAttributeCoordinateAxes;
extern NSString *const EDGraphAttributePoints;
extern NSString *const EDGraphAttributeEquations;
extern NSString *const EDGraphAttributeMinValueX;
extern NSString *const EDGraphAttributeMinValueY;
extern NSString *const EDGraphAttributeMaxValueX;
extern NSString *const EDGraphAttributeMaxValueY;
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
extern NSString *const EDKeyRatioHorizontal;
extern NSString *const EDKeyRatioVertical;
extern float const EDGraphMargin;
extern float const EDGraphInnerMargin;
extern NSString *const EDKeyOriginPositionHorizontal;
extern NSString *const EDKeyOriginPositionVertical;
extern NSString *const EDKeyNumberGridLinesPositive;
extern NSString *const EDKeyNumberGridLinesNegative;
extern float const EDGraphEquationIncrement;
extern float const EDGraphDependentVariableIncrement;
extern int const EDGraphValueMinThresholdMin;
extern int const EDGraphValueMinThresholdMax;
extern int const EDGraphValueMaxThresholdMin;
extern int const EDGraphValueMaxThresholdMax;
extern int const EDGraphScaleMax;
extern int const EDGraphScaleMin;
extern int const EDGraphLabelIntervalMin;
extern int const EDGraphLabelIntervalMax;

// lines
extern float const EDWorksheetLineSelectionWidth;
extern float const EDWorksheetLineSelectionHeight;

// graph points
extern NSString *const EDGraphPointAttributeVisible;
extern NSString *const EDGraphPointAttributeShowLabel;
extern float const EDGraphPointLabelWidth;
extern float const EDGraphPointLabelHeight;
extern float const EDGraphPointLabelVerticalOffset;
extern float const EDGraphPointLabelHorizontalOffset;

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
extern NSString *const EDPageViewSelectionColor;
extern float const EDPageViewSelectionWidth;
extern float const EDPageViewSelectionHeight;
extern float const EDPageViewSelectionAlpha;
extern float const EDPageViewOffsetY;
extern float const EDPageViewIncrementPosY;
extern float const EDPageViewPosX;
extern float const EDPageImageHorizontalBuffer;
extern float const EDPageImageViewWidth;
extern float const EDPageImageViewHeight;
extern float const EDPageViewDragPosX;
extern float const EDPageViewDragOffsetY;
extern float const EDPageViewDragWidth;
extern float const EDPageViewDragLength;
extern int const EDPageViewGraphBorderDrawMultiplier;

// page
extern NSString *const EDPageAttributePageNumber;
extern NSString *const EDPageAttributeSelected;
extern NSString *const EDPageAttributeCurrent;
extern NSString *const EDPageAttributeGraphs;
extern NSString *const EDPageAttributeLines;
extern NSString *const EDPageAttributeTextboxes;
extern NSString *const EDGraphAttributePage;
extern NSString *const EDGraphAttributeScaleX;
extern NSString *const EDGraphAttributeScaleY;
extern NSString *const EDGraphAttributeLabelIntervalX;
extern NSString *const EDGraphAttributeLabelIntervalY;
extern NSString *const EDEventPageClickedWithoutModifier;
extern NSString *const EDEventPageViewMouseDown;
extern float const EDPagesViewWidth;

// keyboard mapping
extern int const        EDKeycodeQuit;
extern int const        EDKeycodeTab;
extern int const        EDKeycodeDelete;
extern int const        EDKeycodeCopy;
extern int const        EDKeycodeCut;
extern int const        EDKeycodePaste;
extern int const        EDKeycodeSave;
extern int const        EDKeycodeGraph;
extern int const        EDKeycodePage;
extern int const        EDKeycodeAll;
extern int const        EDKeycodeDeselect;
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

// equations
extern NSString *const EDEquationAttributeIsVisible;
extern NSString *const EDEquationAttributeShowLabel;
extern NSString *const EDEquationAttributeEquation;
extern NSString *const EDEquationAttributeTokens;
extern NSString *const EDEventQuitDuringEquationSheet;
extern int const EDEquationSheetIndexInvalid;

// tokens
typedef enum{
    EDTokenTypeNumber,
    EDTokenTypeOperator,
    EDTokenTypeIdentifier,
    EDTokenTypeParenthesis,
    EDTokenTypeFunction,
    EDTokenTypeConstant
} EDTokenType;

typedef enum{
    EDAssociationRight,
    EDAssociationLeft
} EDAssociation;

extern NSString *const EDKeyValidEquation;
extern NSString *const EDKeyParsedTokens;
extern NSString *const EDKeyEquation;
extern NSString *const EDTokenAttributeIsValid;
extern NSString *const EDTokenAttributePrecedence;
extern NSString *const EDTokenAttributeValue;
extern NSString *const EDTokenAttributeType;
extern NSString *const EDTokenAttributeAssociation;
extern NSString *const EDTokenAttributeEquation;

// errors
extern NSString *const EDErrorDomain;
extern int const EDErrorTokenizer;

@end