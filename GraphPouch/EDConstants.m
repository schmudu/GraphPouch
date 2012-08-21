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
// entity names
NSString * const EDEntityNameGraph                              = @"EDGraph";

// worksheet events
NSString * const EDEventWorksheetClicked                        = @"EDEventWorksheetClicked";
NSString * const EDEventMouseDown                               = @"EDEventMouseDown";
NSString * const EDEventMouseDragged                            = @"EDEventMouseDragged";
NSString * const EDEventMouseUp                                 = @"EDEventMouseUp";
NSString * const EDEventUnselectedGraphClickedWithoutModifier   = @"EDEventUnselectedGraphClickedWithoutModifier";
NSString * const EDEventDeleteKeyPressedWithoutModifiers        = @"EDEventDeleteKeyPressedWithoutModifiers";
NSString * const EDEventKey                                     = @"EDEvent";

// guides
NSString * const EDKeyGuideVertical                             = @"EDKeyGuideVertical";
NSString * const EDKeyGuideHorizontal                           = @"EDKeyGuideHorizontal";
BOOL const EDSnapToGuide                                        = TRUE;
float const EDGuideThreshold                                    = 5.0;

// element attributes
NSString * const EDElementAttributeSelected                     = @"selected";
NSString * const EDElementAttributeLocationX                    = @"locationX";
NSString * const EDElementAttributeLocationY                    = @"locationY";

// graph attributes
NSString * const EDGraphAttributeTickMarks                      = @"hasTickMarks";
NSString * const EDGraphAttributeEquation                       = @"equation";
NSString * const EDGraphAttributeGrideLines                     = @"hasGridLines";

// keyboard
int const EDKeycodeDelete                                       = 51;
int const EDKeyModifierNone                                     = 256;
@end
