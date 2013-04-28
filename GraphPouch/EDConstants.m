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
#pragma mark context
NSString * const EDKeyContextChild                              = @"EDKeyContextChild";
NSString * const EDKeyContextRoot                               = @"EDKeyContextRoot";

#pragma mark context menu page
NSString *const EDContextMenuPageSelect                         = @"Select page";
NSString *const EDContextMenuPageDeselect                       = @"Deselect page";

#pragma mark context menu pages
NSString *const EDContextMenuPageAdd                            = @"Add page";
NSString *const EDContextMenuPagesSelectAll                     = @"Select all pages";
NSString *const EDContextMenuPagesDeselectAll                   = @"Deselect all pages";
NSString *const EDContextMenuPagesCopy                          = @"Copy page";
NSString *const EDContextMenuPagesCopyPlural                    = @"Copy pages";
NSString *const EDContextMenuPagesCut                           = @"Cut page";
NSString *const EDContextMenuPagesCutPlural                     = @"Cut pages";
NSString *const EDContextMenuPageMakeCurrent                    = @"View page";

NSString *const EDContextMenuPagesPaste                         = @"Paste page";
NSString *const EDContextMenuPagesPastePlural                   = @"Paste pages";
NSString *const EDContextMenuPagesDelete                        = @"Delete page";
NSString *const EDContextMenuPagesDeletePlural                  = @"Delete pages";
NSString *const EDContextMenuPagesPageNext                      = @"Go to next page";
NSString *const EDContextMenuPagesPagePrevious                  = @"Go to previous page";

#pragma mark context menu worksheet
NSString *const EDContextMenuWorksheetSelect                    = @"Select all";
NSString *const EDContextMenuWorksheetDeselect                  = @"Deselect all";
NSString *const EDContextMenuWorksheetCopy                      = @"Copy";
NSString *const EDContextMenuWorksheetCut                       = @"Cut";
NSString *const EDContextMenuWorksheetDelete                    = @"Delete";
NSString *const EDContextMenuWorksheetPaste                     = @"Paste";
NSString *const EDContextMenuWorksheetExpression                = @"Insert Expression";
NSString *const EDContextMenuWorksheetGraph                     = @"Insert Graph";
NSString *const EDContextMenuWorksheetImage                     = @"Insert Image";
NSString *const EDContextMenuWorksheetTextbox                   = @"Insert Textbox";
NSString *const EDContextMenuWorksheetLine                      = @"Insert Line";
NSString *const EDEventCommandExpression                        = @"EDEventCommandExpression";
NSString *const EDEventCommandGraph                             = @"EDEventCommandGraph";
NSString *const EDEventCommandImage                             = @"EDEventCommandImage";
NSString *const EDEventCommandLine                              = @"EDEventCommandLine";
NSString *const EDEventCommandTextbox                           = @"EDEventCommandTextbox";

#pragma mark context menu element
NSString *const EDContextMenuElementSelect                      = @"Select";
NSString *const EDContextMenuElementDeselect                    = @"Deselect";
NSString *const EDContextMenuElementDelete                      = @"Delete";
NSString *const EDContextMenuElementCopy                        = @"Copy";
NSString *const EDContextMenuElementCut                         = @"Cut";

#pragma mark element attributes
NSString * const EDElementAttributeSelected                     = @"selected";
NSString * const EDElementAttributeLocationX                    = @"locationX";
NSString * const EDElementAttributeLocationY                    = @"locationY";
NSString * const EDElementAttributeWidth                        = @"elementWidth";
NSString * const EDElementAttributeHeight                       = @"elementHeight";

#pragma mark entity names
NSString * const EDEntityNameExpression                         = @"EDExpression";
NSString * const EDEntityNameGraph                              = @"EDGraph";
NSString * const EDEntityNameImage                              = @"EDImage";
NSString * const EDEntityNamePage                               = @"EDPage";
NSString * const EDEntityNamePoint                              = @"EDPoint";
NSString * const EDEntityNameEquation                           = @"EDEquation";
NSString * const EDEntityNameToken                              = @"EDToken";
NSString * const EDEntityNameLine                               = @"EDLine";
NSString * const EDEntityNameTextbox                            = @"EDTextbox";

#pragma mark equations
NSString * const EDEquationAttributeEquation                    = @"equation";
NSString * const EDEquationAttributeShowLabel                   = @"showLabel";
NSString * const EDEquationAttributeIsVisible                   = @"isVisible";
NSString * const EDEquationAttributeTokens                      = @"tokens";
NSString * const EDEventQuitDuringEquationSheet                 = @"EDEventQuitDuringEquationSheet";
int const EDEquationSheetIndexInvalid                           = -1;
float const EDEquationMaxThresholdDrawingValue                  = 1.5;
float const EDEquationLineWidth                                 = 1.0;

#pragma mark errors
NSString * const EDErrorDomain                                  = @"com.edcodia.graphpouch";
int const EDErrorTokenizer                                      = 1;

#pragma mark expression
NSString * const EDExpressionAttributeExpression                = @"expression";
NSString * const EDExpressionAttributeFontSize                  = @"fontSize";
NSString * const EDKeyExpressionFirst                           = @"EDKeyExpressionFirst";
NSString * const EDKeyExpressionSecond                          = @"EDKeyExpressionSecond";
NSString * const EDKeyExpressionType                            = @"EDKeyExpressionType";
NSString * const EDKeyParenthesisWidth                          = @"EDKeyParenthesisWidth";
NSString * const EDKeyParenthesisTextField                      = @"EDKeyParenthesisTextField";
float const EDExpressionFontModifierNumerator                   = .7;
float const EDExpressionFontModifierDenominator                 = .7;
//float const EDExpressionFontModifierExponentialBase             = .7;
float const EDExpressionFontModifierExponentialBase             = 1.0;
float const EDExpressionFontModifierExponentialPower            = .7;
float const EDExpressionDefaultFontSize                         = 14.0;
float const EDExpressionBufferHorizontalAddSubtract             = 2.0;
float const EDExpressionAdditionLeftVerticalOffset              = 2.0;
NSString * const EDExpressionDefaultFontName                    = @"Lucida Console";
float const EDExpressionAddSubtractVerticalModifier             = -0.1;
float const EDExpressionAddSubtractHorizontalModifier           = 0.1;
float const EDExpressionFontSizeMinimum                         = 6.0;
float const EDExpressionFontSizeMaximum                         = 100.0;
float const EDExpressionLeftDenominatorRootModifierSize         = 2.0;
float const EDExpressionRadicalLineWidthPrimary                 = 0.5;
float const EDExpressionRadicalLineWidthSecondary               = 0.3;
float const EDExpressionRadicalLineWidthTertiary                = 0.2;
float const EDExpressionRadicalLineHeightTertiary               = 0.9;
float const EDExpressionRadicalRootUpperLeftOriginOffset        = 4.0;
float const EDExpressionRadicalPowerOffsetVertical              = 4.0;
float const EDExpressionRadicalRootLowerLeftOriginOffset        = 15.0;
float const EDExpressionRadicalBaseUpperLeftOriginOffset        = 0.0;
float const EDExpressionTextFieldEndBuffer                      = 1.7;
float const EDExpressionTextFieldEndBufferModifier              = 0.1;
float const EDExpressionExponentPowerExponentModifierVertical   = -0.7;
float const EDExpressionSymbolMultiplicationSymbolFontModifier  = 0.8;
float const EDExpressionDefaultWidth                            = 150;
float const EDExpressionDefaultHeight                           = 50;
//float const EDExpressionXHeightRatio                            = 0.405;
float const EDExpressionXHeightRatio                            = 0.47;
float const EDExpressionDivisionLineWidth                       = 1.0;
float const EDExpressionDivisionGapVertical                     = 1.0;
float const EDExpressionMultiplierModifierVertical              = -.2;

#pragma mark general
NSString * const EDKey                                          = @"EDKey";
NSString * const EDValue                                        = @"EDValue";
NSString * const EDSelectedViewColor                            = @"3E8DD3";
float const EDSelectedViewStrokeWidth                            = 2.0;

#pragma mark graph attributes
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
NSString * const EDGraphBorderColor                             = @"000000";
float const EDPageViewGraphBorderLineWidth                      = 0.5;
float const EDGraphDefaultCoordinateLineWidth                   = 1.5;
float const EDCoordinateArrowWidth                              = 5.0;
float const EDCoordinateArrowLength                             = 10.0;
float const EDGridDistanceMinimumThreshold                      = 20.0;
int const EDGridMaximum                                         = 10;
float const EDGridIncrementalMaximum                            = 70;
float const EDGridIncrementalMinimum                            = 20;
NSString * const EDGridColor                                    = @"666666";
float const EDGridAlpha                                         = 0.8;
NSString * const EDKeyGridFactor                                = @"EDKeyGridFactor";
NSString * const EDKeyDistanceIncrement                         = @"EDKeyDistanceIncrement";
NSString * const EDKeyGridLinesCount                            = @"EDKeyGridLinesCount";
float const EDGraphTickLength                                   = 4;
float const EDGraphVerticalLabelHorizontalOffset                = 6.0;
float const EDGraphVerticalLabelVerticalOffset                  = 7.0;
float const EDGraphHorizontalLabelHorizontalOffset              = -5;
float const EDGraphHorizontalLabelVerticalOffset                = 5;
float const EDGraphHorizontalLabelHorizontalNegativeOffset      = 6;
float const EDGraphXLabelHorizontalOffset                       = -6;
float const EDGraphYLabelVerticalOffset                         = 2;
float const EDGraphPointDiameter                                = 5;
NSString * const EDKeyRatioHorizontal                           = @"EDKeyRatioHorizontal";
NSString * const EDKeyRatioVertical                             = @"EDKeyRatioVertical";
float const EDGraphMargin                                       = 0;
float const EDGraphInnerMargin                                  = 20;
NSString * const EDKeyOriginPositionHorizontal                  = @"EDKeyOriginPositionHorizontal";
NSString * const EDKeyOriginPositionVertical                    = @"EDKeyOriginPositionVertical";
NSString * const EDKeyNumberGridLinesPositive                   = @"EDKeyNumberGridLinesPositive";
NSString * const EDKeyNumberGridLinesNegative                   = @"EDKeyNumberGridLinesNegative";
float const EDGraphEquationIncrement                            = .25;
int const EDGraphValueMinThresholdMin                           = -1000;
int const EDGraphValueMinThresholdMax                           = 0;
int const EDGraphValueMaxThresholdMin                           = 0;
int const EDGraphValueMaxThresholdMax                           = 1000;
int const EDGraphScaleMax                                       = 1000;
int const EDGraphScaleMin                                       = 1;
int const EDGraphLabelIntervalMax                               = 100;
int const EDGraphLabelIntervalMin                               = 1;

float const EDWorksheetLineSelectionHeight                      = 50;
float const EDWorksheetLineSelectionWidth                       = 300;

#pragma mark graph points
NSString * const EDGraphPointAttributeVisible                   = @"isVisible";
NSString * const EDGraphPointAttributeShowLabel                 = @"showLabel";
float const EDGraphPointLabelHeight                             = 20;
float const EDGraphPointLabelWidth                              = 60;
float const EDGraphPointLabelVerticalOffset                     = 1;
float const EDGraphPointLabelHorizontalOffset                   = 8;
float const EDGraphDependentVariableIncrement                   = 5.0;        // the higher the number the more accurate the graphs, but worse performance

#pragma mark guides
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
float const EDGuideWidth                                        = 2.0;
float const EDGuideShowThreshold                                = 10.0;  // diff must be less then this to show guide

#pragma mark image
NSString * const EDImageAttributeImageData                      =  @"imageData";
NSString * const EDEventImageMatchDimensions                    =  @"EDEventImageMatchDimensions";

#pragma mark keyboard
int const EDKeycodeSave                                         = 1;
int const EDKeycodeTab                                          = 48;
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
int const EDKeycodeArrowLeft                                    = 123;
int const EDKeycodeArrowUp                                      = 126;
int const EDKeycodeArrowRight                                   = 124;
int const EDKeycodeArrowDown                                    = 125;

#pragma mark layout
float const EDMenuToolbarHeight                                 = 89;

#pragma mark line
NSString * const EDLineAttributeThickness                       = @"thickness";

#pragma mark menu
NSString * const EDEventMenuAlignTop                            = @"EDEventMenuAlignTop";
NSString * const EDEventShortcutNewPage                         = @"EDEventShortcutNewPage";
NSString * const EDEventShortcutCopy                            = @"EDEventShortcutCopy";
NSString * const EDEventShortcutCut                             = @"EDEventShortcutCut";
NSString * const EDEventShortcutDelete                          = @"EDEventShortcutDelete";
NSString * const EDEventShortcutPaste                           = @"EDEventShortcutPaste";
NSString * const EDEventShortcutSave                            = @"EDEventShortcutSave";
NSString * const EDEventShortcutGraph                           = @"EDEventShortcutGraph";
NSString * const EDEventShortcutPage                            = @"EDEventShortcutPage";
NSString * const EDEventShortcutSelectAll                       = @"EDEventShortcutSelectAll";
NSString * const EDEventShortcutDeselectAll                     = @"EDEventShortcutDeselectAll";

float const EDMenuToolbarShadowWidth                            = 2.0;

#pragma mark numbers
float const EDNumberMax                                         = 9999999;

#pragma mark preferences
NSString * const EDPreferenceSnapToGuides                       = @"EDPreferenceSnapToGuides";
NSString * const EDPreferencePropertyPanel                      = @"EDPreferencePropertyPanel";

#pragma mark page view
NSString * const EDPageAttributePageNumber                      = @"pageNumber";
NSString * const EDPageAttributeSelected                        = @"selected";
NSString * const EDPageAttributeCurrent                         = @"currentPage";
NSString * const EDPageAttributeExpressions                     = @"expressions";
NSString * const EDPageAttributeGraphs                          = @"graphs";
NSString * const EDPageAttributeImages                          = @"images";
NSString * const EDPageAttributeLines                           = @"lines";
NSString * const EDPageAttributeTextboxes                       = @"textboxes";
NSString * const EDGraphAttributePage                           = @"page";
NSString * const EDGraphAttributeScaleX                         = @"scaleX";
NSString * const EDGraphAttributeScaleY                         = @"scaleY";
NSString * const EDGraphAttributeLabelIntervalX                 = @"labelIntervalX";
NSString * const EDGraphAttributeLabelIntervalY                 = @"labelIntervalY";
NSString * const EDEventPageClickedWithoutModifier              = @"EDEventPageClickedWithoutModifier";
NSString * const EDEventPageViewMouseDown                       = @"EDEventPageViewMouseDown";

#pragma mark pages view
NSString * const EDEventPagesWillBeRemoved                      = @"EDEventPagesWillBeRemoved";
NSString * const EDKeyPagesToRemove                             = @"EDKeyPageToRemove";
NSString * const EDEventPagesViewClicked                        = @"EDEventPagesViewClicked";
NSString * const EDEventPagesDeletePressed                      = @"EDEventPagesDeletePressed";
NSString * const EDEventPagesPastePressed                       = @"EDEventPagesPastePressed";
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
float const EDPageImageHorizontalBuffer                         = 40.0;
float const EDPageImageViewWidth                                = 61.81;
float const EDPageImageViewHeight                               = 80;
float const EDPageViewDragPosX                                  = 30;
float const EDPageViewDragOffsetY                               = -5;
float const EDPageViewDragWidth                                 = 80;
float const EDPageViewDragLength                                = 10;
float const EDPagesViewWidth                                    = 140;
int const EDPageViewGraphBorderDrawMultiplier                   = 2;

#pragma mark panels
NSString * const EDKeyExpression                                = @"EDKeyExpression";
NSString * const EDKeyGraph                                     = @"EDKeyGraph";
NSString * const EDKeyImage                                     = @"EDKeyImage";
NSString * const EDKeyLine                                      = @"EDKeyLine";
NSString * const EDKeyTextbox                                   = @"EDKeyTextbox";
NSString * const EDKeyBasic                                     = @"EDKeyBasic";
NSString * const EDKeyBasicWithoutHeight                        = @"EDKeyBasicWithoutHeight";
/*
NSString * const EDKeyExpression                                = @"EDKeyExpression";
NSString * const EDKeyExpressionGraph                           = @"EDKeyExpressionGraph";
NSString * const EDKeyExpressionGraphLine                       = @"EDKeyExpressionGraphLine";
NSString * const EDKeyExpressionGraphLineTextbox                = @"EDKeyExpressionGraphLineTextbox";
NSString * const EDKeyExpressionGraphTextbox                    = @"EDKeyExpressionGraphTextbox";
NSString * const EDKeyExpressionLine                            = @"EDKeyExpressionLine";
NSString * const EDKeyExpressionLineTextbox                     = @"EDKeyExpressionLineTextbox";
NSString * const EDKeyExpressionTextbox                         = @"EDKeyExpressionTextbox";
NSString * const EDKeyGraph                                     = @"EDKeyGraph";
NSString * const EDKeyGraphLine                                 = @"EDKeyGraphLine";
NSString * const EDKeyGraphLineTextbox                          = @"EDKeyGraphLineTextbox";
NSString * const EDKeyGraphTextbox                              = @"EDKeyGraphTextbox";
NSString * const EDKeyLine                                      = @"EDKeyLine";
NSString * const EDKeyLineTextbox                               = @"EDKeyLineTextbox";
NSString * const EDKeyTextbox                                   = @"EDTextbox";
*/
NSString * const EDEventPanelDocumentPressedDate                = @"EDEventPanelDocumentPressedDate";
NSString * const EDEventPanelDocumentPressedName                = @"EDEventPanelDocumentPressedName";

#pragma mark panel events
NSString * const EDEventControlReceivedFocus                    = @"EDEventControlReceivedFocus";

#pragma mark saving
float const EDAutosaveTimeIncrement                             = 10.0;

#pragma mark textfield
NSString * const EDTextboxAttributeTextValue                    = @"textValue";
NSString * const EDKeyEvent                                     = @"EDKeyEvent";
float const EDTextboxBorderWidth                                = 1.0;
float const EDFontDefaultSize                                   = 10.0;
float const EDFontDefaultSizeTextbox                            = 10.0;
NSString * const EDEventTextboxBeginEditing                     = @"EDEventTextboxBeginEditing";
NSString * const EDEventTextboxDidChange                        = @"EDEventTextboxDidChange";
NSString * const EDEventTextboxEndEditing                       = @"EDEventTextboxEndEditing";
NSString * const EDKeyTextView                                  = @"EDKeyTextView";
NSString * const EDFontAttributeName                            = @"EDFontAttributeName";
NSString * const EDFontAttributeSize                            = @"EDFontAttributeSize";
NSString * const EDFontAttributeColor                           = @"EDFontAttributeColor";
NSString * const EDEventControlDidChange                        = @"EDEventControlDidChange";
NSString * const EDFontAttributeNameMixed                       = @"<Mixed Fonts>";
NSString * const EDFontAttributeBold                            = @"EDFontAttributeBold";
NSString * const EDFontAttributeItalic                          = @"EDFontAttributeItalic";
NSString * const EDFontAttributeSuperscript                     = @"EDFontAttributeSuperscript";
NSString * const EDTextViewDefaultString                        = @"Double click here to add your text";

#pragma mark tokenize
NSString * const EDKeyValidEquation                             = @"EDKeyValidEquation";
NSString * const EDKeyParsedTokens                              = @"EDKeyParsedTokens";
NSString * const EDKeyEquation                                  = @"EDKeyEquation";
NSString *const EDTokenAttributeIsValid                         = @"isValid";
NSString *const EDTokenAttributeIsImplicit                      = @"isImplicit";
NSString *const EDTokenAttributeParenthesisCount                = @"parenthesisCount";
NSString *const EDTokenAttributePrecedence                      = @"precedence";
NSString *const EDTokenAttributeValue                           = @"tokenValue";
NSString *const EDTokenAttributeType                            = @"type";
NSString *const EDTokenAttributeAssociation                     = @"association";
NSString *const EDTokenAttributeEquation                        = @"equation";

#pragma mark transform
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

#pragma mark UTI
NSString * const EDUTIPage                                      = @"com.edcodia.graphpouch.page";
NSString * const EDUTIPageView                                  = @"com.edcodia.graphpouch.pageview";
NSString * const EDUTIGraph                                     = @"com.edcodia.graphpouch.graph";
NSString * const EDUTIGraphView                                 = @"com.edcodia.graphpouch.graphView";
NSString * const EDUTIImage                                     = @"com.edcodia.graphpouch.image";
NSString * const EDUTIImageView                                 = @"com.edcodia.graphpouch.imageView";
NSString * const EDUTIToken                                     = @"com.edcodia.graphpouch.token";
NSString * const EDUTIEquation                                  = @"com.edcodia.graphpouch.equation";
NSString * const EDUTILine                                      = @"com.edcodia.graphpouch.line";
NSString * const EDUTITextbox                                   = @"com.edcodia.graphpouch.textbox";
NSString * const EDUTIExpression                                = @"com.edcodia.graphpouch.expression";

#pragma mark worksheet
float const EDWorksheetViewWidth                                = 612;
float const EDWorksheetViewHeight                               = 792;
float const EDWorksheetShadowSize                               = 2.0;
NSString * const EDWorksheetShadowColor                         = @"333333";
float const EDIncrementPressedArrowModifier                     = 10.0;
float const EDIncrementPressedArrow                             = 2.0;
float const EDCopyLocationOffset                                = 50.0;
NSString * const EDKeyPointDown                                 = @"EDKeyPointDown";
NSString * const EDKeyPointDrag                                 = @"EDKeyPointDrag";
NSString * const EDEventDraggingMouseStart                      = @"EDEventDraggingMouseStart";
NSString * const EDEventDraggingMouseFinish                     = @"EDEventDraggingMouseFinish";

#pragma mark worksheet elements
NSString * const EDEventMouseDoubleClick                        = @"EDEventMouseDoubleClick";
NSString * const EDEventWorksheetClicked                        = @"EDEventWorksheetClicked";
NSString * const EDEventMouseDown                               = @"EDEventMouseDown";
NSString * const EDEventMouseDragged                            = @"EDEventMouseDragged";
NSString * const EDEventMouseUp                                 = @"EDEventMouseUp";
NSString * const EDEventUnselectedElementClickedWithoutModifier   = @"EDEventUnselectedElementClickedWithoutModifier";
NSString * const EDEventDeleteKeyPressedWithoutModifiers        = @"EDEventDeleteKeyPressedWithoutModifiers";
NSString * const EDEventTabPressedWithoutModifiers              = @"EDEventTabPressedWithoutModifiers";
NSString * const EDEventBecomeFirstResponder                    = @"EDEventBecomeFirstResponder";
NSString * const EDEventWorksheetElementSelected                = @"EDEventWorksheetElementSelected";
NSString * const EDEventWorksheetElementDeselected              = @"EDEventWorksheetElementDeselected";
NSString * const EDEventWorksheetViewResignFirstResponder       = @"EDEventWorksheetViewResignFirstResponder";
NSString * const EDEventKey                                     = @"EDEvent";
NSString * const EDEventWorksheetElementRedrawingItself         = @"EDEventWorksheetElementRedrawingItself";
NSString * const EDEventArrowKeyPressed                         = @"EDEventArrowKeyPressed";

#pragma mark window
NSString * const EDEventWindowDidResize                         = @"EDEventWindowDidResize";
NSString * const EDEventWindowWillClose                         = @"EDEventWindowWillClose";
float const EDMainWindowTitleBarHeight                          = 60.0;
NSString * const EDEventWindowSettingTitle                      = @"EDEventWindowSettingTitle";
@end
