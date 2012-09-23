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
// preferences
NSString * const EDPreferenceSnapToGuides                       = @"EDPreferenceSnapToGuides";
NSString * const EDPreferencePropertyPanel                      = @"EDPreferencePropertyPanel";

// entity names
NSString * const EDEntityNameGraph                              = @"EDGraph";

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
NSString * const EDEventMenuAlignTop                             = @"EDEventMenuAlignTop";

// guides
NSString * const EDKeyGuideVertical                             = @"EDKeyGuideVertical";
NSString * const EDKeyGuideHorizontal                           = @"EDKeyGuideHorizontal";
NSString * const EDKeySnapOffset                                = @"EDKeySnapOffset";
NSString * const EDKeyClosestGuide                              = @"EDKeyClosestGuide";
NSString * const EDKeyGuideDiff                                 = @"EDKeyGuideDiff";
NSString * const EDKeyDiff                                      = @"EDKeyDiff";
NSString * const EDKeyValue                                     = @"EDKeyValue";
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
NSString * const EDGraphAttributeTickMarks                      = @"hasTickMarks";
NSString * const EDGraphAttributeEquation                       = @"equation";
NSString * const EDGraphAttributeGrideLines                     = @"hasGridLines";
float const EDGraphDefaultHeight                                = 30.0;
float const EDGraphDefaultWidth                                 = 30.0;

// keyboard
int const EDKeycodeDelete                                       = 51;
int const EDKeyModifierNone                                     = 256;

// transform
float const EDTransformPointLength                              = 10;
NSString * const EDEventTransformPointMoved                     = @"EDEventTransformPointMoved";
@end
