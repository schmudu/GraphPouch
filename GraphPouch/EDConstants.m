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
    NSString * const EDEventGraphAdded           = @"EDGraphAdded";

    // graphs
    NSString * const EDEventElementClicked                    = @"EDEventElementClicked";
    NSString * const EDEventElementClickedWithCommand         = @"EDEventElementClickedWithCommand";
    NSString * const EDEventElementClickedWithShift           = @"EDEventElementClickedWithShift";

    // worksheets
    NSString * const EDEventWorksheetClicked                 = @"EDEventWorksheetClicked";
    NSString * const EDEventWorksheetElementAdded            = @"EDEventWorksheetElementAdded";
    NSString * const EDEventWorksheetElementRemoved          = @"EDEventWorksheetElementRemoved";
@end
