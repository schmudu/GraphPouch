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
    // graph
    extern NSString *const EDNotificationGraphAdded;
    extern NSString *const EDNotificationGraphSelected;
    extern NSString *const EDNotificationGraphSelectedWithComand;
    extern NSString *const EDNotificationGraphSelectedWithShift;
    extern NSString *const EDNotificationGraphDeselected;

    // worksheet
    extern NSString *const EDNotificationWorksheetClicked;
    extern NSString *const EDNotificationWorksheetElementAdded;
    extern NSString *const EDNotificationWorksheetElementRemoved;
@end
