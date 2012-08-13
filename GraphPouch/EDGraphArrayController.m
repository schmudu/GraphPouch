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
    NSString *value_equation = [[NSString alloc] initWithString:@"default_equation"];
    [newObj setValue:value_equation forKey:@"equation"];
    
    NSNumber *value_has_tick_marks = [[NSNumber alloc] initWithInt:GRAPH_INIT_TICK_MARKS];
    [newObj setValue:value_has_tick_marks forKey:@"hasTickMarks"];
    
    NSNumber *value_grid_lines = [[NSNumber alloc] initWithInt:GRAPH_INIT_HAS_GRID_LINES];
    [newObj setValue:value_grid_lines forKey:@"hasGridLines"];
    
    NSNumber *value_location = [[NSNumber alloc] initWithFloat:0];
    [newObj setValue:value_location forKey:@"locationX"];
    [newObj setValue:value_location forKey:@"locationY"];
    
    // selected
    [newObj setValue:[[NSNumber alloc] initWithInt:0] forKey:@"selected"];
    NSLog(@"set value for selected:%@ obj:%@", [newObj valueForKey:@"selected"], newObj);
    //[newObj setBool:FALSE forKey:@"selected"];
    // send notification
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //[nc postNotificationName:EDEventGraphAdded object:newObj];
    
    return newObj;
}

@end
