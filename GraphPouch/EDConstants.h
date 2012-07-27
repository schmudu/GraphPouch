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
    extern NSString *const EDEventGraphAdded;
    extern NSString *const EDEventElementSelected;
    extern NSString *const EDEventElementSelectedWithComand;
    extern NSString *const EDEventElementSelectedWithShift;
    extern NSString *const EDEventElementDeselected;

    // worksheet
    extern NSString *const EDEventWorksheetClicked;
    extern NSString *const EDEventWorksheetElementAdded;
    extern NSString *const EDEventWorksheetElementRemoved;
@end
