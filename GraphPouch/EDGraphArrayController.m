//
//  EDGraphArrayController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraphArrayController.h"
#import "EDConstants.h"

@implementation EDGraphArrayController

- (id)newObject{
    id newObj = [super newObject];
    //NSLog(@"object type: %@", [newObj class]);
    
    // default values
    NSNumber *value_has_tick_marks = [[NSNumber alloc] initWithInt:GRAPH_INIT_TICK_MARKS];
    [newObj setValue:value_has_tick_marks forKey:@"hasTickMarks"];
    
    NSNumber *value_grid_lines = [[NSNumber alloc] initWithInt:GRAPH_INIT_HAS_GRID_LINES];
    [newObj setValue:value_grid_lines forKey:@"hasGridLines"];
    
    // send notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"sending notification");
    [nc postNotificationName:EDEventGraphAdded object:newObj];
    
    return newObj;
}

@end
