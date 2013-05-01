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

#pragma mark attributes
extern NSString *const EDGraphAttributeLabels;
extern NSString *const EDGraphBorderColor;
extern float const EDPageViewGraphBorderLineWidth;
extern NSString *const EDGraphAttributeGridLines;
extern NSString *const EDElementAttributeZIndex;
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

#pragma mark context
extern NSString *const EDKeyContextChild;
extern NSString *const EDKeyContextRoot;

#pragma mark context menu pages
extern NSString *const EDContextMenuPageSelect;
extern NSString *const EDContextMenuPageDeselect;

#pragma mark context menu pages
extern NSString *const EDContextMenuPageAdd;
extern NSString *const EDContextMenuPagesSelectAll;
extern NSString *const EDContextMenuPagesDeselectAll;
extern NSString *const EDContextMenuPagesCopy;
extern NSString *const EDContextMenuPagesCopyPlural;
extern NSString *const EDContextMenuPagesCut;
extern NSString *const EDContextMenuPagesCutPlural;
extern NSString *const EDContextMenuPagesPaste;
extern NSString *const EDContextMenuPagesPastePlural;
extern NSString *const EDContextMenuPagesDelete;
extern NSString *const EDContextMenuPagesDeletePlural;
extern NSString *const EDContextMenuPagesPageNext;
extern NSString *const EDContextMenuPagesPagePrevious;
extern NSString *const EDContextMenuPageMakeCurrent;

#pragma mark context menu element
extern NSString *const EDContextMenuElementSelect;
extern NSString *const EDContextMenuElementDeselect;
extern NSString *const EDContextMenuElementDelete;
extern NSString *const EDContextMenuElementCopy;
extern NSString *const EDContextMenuElementCut;

#pragma mark context menu worksheet
extern NSString *const EDContextMenuWorksheetDeselect;
extern NSString *const EDContextMenuWorksheetSelect;
extern NSString *const EDContextMenuWorksheetExpression;
extern NSString *const EDContextMenuWorksheetGraph;
extern NSString *const EDContextMenuWorksheetImage;
extern NSString *const EDContextMenuWorksheetTextbox;
extern NSString *const EDContextMenuWorksheetLine;
extern NSString *const EDContextMenuWorksheetCopy;
extern NSString *const EDContextMenuWorksheetCut;
extern NSString *const EDContextMenuWorksheetPaste;
extern NSString *const EDContextMenuWorksheetDelete;
extern NSString *const EDEventCommandExpression;
extern NSString *const EDEventCommandGraph;
extern NSString *const EDEventCommandImage;
extern NSString *const EDEventCommandLine;
extern NSString *const EDEventCommandTextbox;


#pragma mark directions
typedef enum{
    EDDirectionLeft,
    EDDirectionUp,
    EDDirectionRight,
    EDDirectionDown
} EDDirection;

#pragma mark entity name
extern NSString *const EDEntityNameGraph;
extern NSString *const EDEntityNameImage;
extern NSString *const EDEntityNamePage;
extern NSString *const EDEntityNamePoint;
extern NSString *const EDEntityNameEquation;
extern NSString *const EDEntityNameToken;
extern NSString *const EDEntityNameLine;
extern NSString *const EDEntityNameTextbox;
extern NSString *const EDEntityNameExpression;

#pragma mark equations
extern NSString *const EDEquationAttributeIsVisible;
extern NSString *const EDEquationAttributeShowLabel;
extern NSString *const EDEquationAttributeEquation;
extern NSString *const EDEquationAttributeTokens;
extern NSString *const EDEventQuitDuringEquationSheet;
extern int const EDEquationSheetIndexInvalid;
extern float const EDEquationMaxThresholdDrawingValue;
extern float const EDEquationLineWidth;

#pragma mark errors
extern NSString *const EDErrorDomain;
extern int const EDErrorTokenizer;

#pragma mark expression
typedef enum{
    EDTypeExpression,
    EDTypeEquation
} EDExpressionType;

extern NSString *const EDExpressionAttributeExpression;
extern NSString *const EDExpressionAttributeFontSize;
extern NSString *const EDKeyExpressionFirst;
extern NSString *const EDKeyExpressionSecond;
extern NSString *const EDKeyExpressionType;
extern NSString *const EDKeyParenthesisWidth;
extern NSString *const EDKeyParenthesisTextField;

extern float const EDExpressionFontModifierNumerator;
extern float const EDExpressionFontModifierDenominator;
extern float const EDExpressionFontModifierExponentialBase;
extern float const EDExpressionFontModifierExponentialPower;
extern float const EDExpressionDefaultFontSize;
extern float const EDExpressionBufferHorizontalAddSubtract;
extern float const EDExpressionAdditionLeftVerticalOffset;
extern NSString *const EDExpressionDefaultFontName;
extern float const EDExpressionAddSubtractVerticalModifier;
extern float const EDExpressionAddSubtractHorizontalModifier;
extern float const EDExpressionFontSizeMinimum;
extern float const EDExpressionFontSizeMaximum;
extern float const EDExpressionLeftDenominatorRootModifierSize;
extern float const EDExpressionRadicalLineWidthPrimary;
extern float const EDExpressionRadicalLineWidthSecondary;
extern float const EDExpressionRadicalLineWidthTertiary;
extern float const EDExpressionRadicalLineHeightTertiary;
extern float const EDExpressionRadicalRootUpperLeftOriginOffset;
extern float const EDExpressionRadicalRootLowerLeftOriginOffset;
extern float const EDExpressionRadicalBaseUpperLeftOriginOffset;
extern float const EDExpressionRadicalPowerOffsetVertical;
extern float const EDExpressionTextFieldEndBuffer;
extern float const EDExpressionTextFieldEndBufferModifier;
extern float const EDExpressionExponentPowerExponentModifierVertical;
extern float const EDExpressionSymbolMultiplicationSymbolFontModifier;
extern float const EDExpressionDefaultWidth;
extern float const EDExpressionDefaultHeight;
extern float const EDExpressionXHeightRatio;
extern float const EDExpressionDivisionLineWidth;
extern float const EDExpressionDivisionGapVertical;
extern float const EDExpressionMultiplierModifierVertical;

#pragma mark general
extern NSString *const EDKey;
extern NSString *const EDValue;
extern NSString *const EDSelectedViewColor;
extern float const EDSelectedViewStrokeWidth;

#pragma mark graphs
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

#pragma mark graph points
extern NSString *const EDGraphPointAttributeVisible;
extern NSString *const EDGraphPointAttributeShowLabel;
extern float const EDGraphPointLabelWidth;
extern float const EDGraphPointLabelHeight;
extern float const EDGraphPointLabelVerticalOffset;
extern float const EDGraphPointLabelHorizontalOffset;

#pragma mark keyboard mapping
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
extern int const        EDKeycodeArrowLeft;
extern int const        EDKeycodeArrowUp;
extern int const        EDKeycodeArrowRight;
extern int const        EDKeycodeArrowDown;

#pragma mark guides
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

#pragma mark layout
extern float const EDMenuToolbarHeight;

#pragma mark line
extern NSString *const EDLineAttributeThickness;
extern float const EDWorksheetLineSelectionWidth;
extern float const EDWorksheetLineSelectionHeight;

#pragma mark menu
extern NSString *const EDEventMenuAlignTop;
extern NSString *const EDEventShortcutNewPage;
extern NSString *const EDEventShortcutCopy;
extern NSString *const EDEventShortcutCut;
extern NSString *const EDEventShortcutDelete;
extern NSString *const EDEventShortcutPaste;
extern NSString *const EDEventShortcutSave;
extern NSString *const EDEventShortcutGraph;
extern NSString *const EDEventShortcutPage;
extern NSString *const EDEventShortcutSelectAll;
extern NSString *const EDEventShortcutDeselectAll;
extern float const EDMenuToolbarShadowWidth;

#pragma mark image
extern NSString *const EDImageAttributeImageData;
extern NSString *const EDEventImageMatchDimensions;

#pragma mark num
extern float const EDNumberMax;

#pragma mark pages
extern NSString *const EDEventPagesViewClicked;
extern NSString *const EDEventPagesWillBeRemoved;
extern NSString *const EDKeyPagesToRemove;
//extern NSString *const EDEventPageViewDragged;
extern NSString *const EDEventPagesDeletePressed;
extern NSString *const EDEventPagesPastePressed;
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

#pragma mark page
extern NSString *const EDPageAttributePageNumber;
extern NSString *const EDPageAttributeSelected;
extern NSString *const EDPageAttributeCurrent;
extern NSString *const EDPageAttributeExpressions;
extern NSString *const EDPageAttributeGraphs;
extern NSString *const EDPageAttributeImages;
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


#pragma mark panels
extern NSString *const EDKeyExpression;
extern NSString *const EDKeyGraph;
extern NSString *const EDKeyImage;
extern NSString *const EDKeyLine;
extern NSString *const EDKeyTextbox;
extern NSString *const EDKeyBasic;
extern NSString *const EDKeyBasicWithoutHeight;

/*
extern NSString *const EDKeyExpression;
extern NSString *const EDKeyExpressionGraph;
extern NSString *const EDKeyExpressionGraphLine;
extern NSString *const EDKeyExpressionGraphLineTextbox;
extern NSString *const EDKeyExpressionGraphTextbox;
extern NSString *const EDKeyExpressionLine;
extern NSString *const EDKeyExpressionLineTextbox;
extern NSString *const EDKeyExpressionTextbox;
extern NSString *const EDKeyGraphLine;
extern NSString *const EDKeyGraphLineTextbox;
extern NSString *const EDKeyGraph;
extern NSString *const EDKeyGraphTextbox;
extern NSString *const EDKeyLine;
extern NSString *const EDKeyLineTextbox;
extern NSString *const EDKeyTextbox;
 */
extern NSString *const EDEventPanelDocumentPressedDate;
extern NSString *const EDEventPanelDocumentPressedName;

#pragma mark panel events
extern NSString *const EDEventControlReceivedFocus;

#pragma mark preferences
extern NSString *const EDPreferenceSnapToGuides;
extern NSString *const EDPreferencePropertyPanel;

#pragma mark saving
extern float const EDAutosaveTimeIncrement;

#pragma mark textfield
extern NSString *const EDTextboxAttributeTextValue;
extern NSString *const EDKeyEvent;
extern float const EDTextboxBorderWidth;
extern NSString *const EDEventTextboxBeginEditing;
extern NSString *const EDEventTextboxEndEditing;
extern NSString *const EDEventTextboxDidChange;
extern NSString *const EDKeyTextView;
extern NSString *const EDFontAttributeName;
extern float const EDFontDefaultSize;
extern float const EDFontDefaultSizeTextbox;
extern NSString *const EDFontAttributeSize;
extern NSString *const EDFontAttributeColor;
extern NSString *const EDEventControlDidChange;
extern NSString *const EDFontAttributeNameMixed;
extern NSString *const EDFontAttributeBold;
extern NSString *const EDFontAttributeItalic;
extern NSString *const EDFontAttributeSuperscript;
extern NSString *const EDTextViewDefaultString;

#pragma mark tokens
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
extern NSString *const EDTokenAttributeIsImplicit;
extern NSString *const EDTokenAttributeParenthesisCount;
extern NSString *const EDTokenAttributePrecedence;
extern NSString *const EDTokenAttributeValue;
extern NSString *const EDTokenAttributeType;
extern NSString *const EDTokenAttributeAssociation;
extern NSString *const EDTokenAttributeEquation;


#pragma mark transform
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

#pragma mark UTI
extern NSString *const EDUTIPage;
extern NSString *const EDUTIPageView;
extern NSString *const EDUTIGraph;
extern NSString *const EDUTIGraphView;
extern NSString *const EDUTIImage;
extern NSString *const EDUTIImageView;
extern NSString *const EDUTIToken;
extern NSString *const EDUTIEquation;
extern NSString *const EDUTILine;
extern NSString *const EDUTITextbox;
extern NSString *const EDUTIExpression;

#pragma mark worksheet
extern float const EDWorksheetViewHeight;
extern float const EDWorksheetViewWidth;
extern float const EDWorksheetShadowSize;
extern NSString *const EDWorksheetShadowColor;
extern float const EDIncrementPressedArrowModifier;
extern float const EDIncrementPressedArrow;
extern float const EDCopyLocationOffset;
extern NSString *const EDKeyPointDrag;
extern NSString *const EDKeyPointDown;
extern NSString *const EDEventDraggingMouseStart;
extern NSString *const EDEventDraggingMouseFinish;

#pragma mark worksheet events
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
extern NSString *const EDEventWorksheetElementRedrawingItself;
extern NSString *const EDEventWorksheetViewResignFirstResponder;
extern NSString *const EDEventKey;
extern NSString *const EDEventArrowKeyPressed;

#pragma mark window
extern NSString *const EDEventWindowDidResize;
extern NSString *const EDEventWindowWillClose;
extern float const EDMainWindowTitleBarHeight;
extern NSString *const EDEventWindowSettingTitle;
@end