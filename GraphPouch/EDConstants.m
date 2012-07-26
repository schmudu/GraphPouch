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
    NSString * const EDNotificationGraphAdded           = @"EDGraphAdded";

    // graphs
    NSString * const EDNotificationGraphDeselected                  = @"EDNotificationGraphDeselected";
    NSString * const EDNotificationGraphSelected                    = @"EDNotificationGraphSelected";
    NSString * const EDNotificationGraphSelectedWithComand          = @"EDNotificationGraphSelectedWithCommand";
    NSString * const EDNotificationGraphSelectedWithShift           = @"EDNotificationGraphSelectedWithShift";

    // worksheets
    NSString * const EDNotificationWorksheetClicked                 = @"EDNotificationWorksheetClicked";
    NSString * const EDNotificationWorksheetElementAdded            = @"EDNotificationWorksheetElementAdded";
    NSString * const EDNotificationWorksheetElementRemoved          = @"EDNotificationWorksheetElementRemoved";
@end
