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
    
    // default values
    [newObj setValue:[[NSNumber alloc] initWithBool:GRAPH_INIT_TICK_MARKS] forKey:EDGraphAttributeTickMarks];
    [newObj setValue:[[NSNumber alloc] initWithBool:GRAPH_INIT_HAS_GRID_LINES] forKey:EDGraphAttributeGridLines];
    [newObj setValue:[[NSNumber alloc] initWithFloat:0] forKey:EDElementAttributeLocationX];
    [newObj setValue:[[NSNumber alloc] initWithFloat:0] forKey:EDElementAttributeLocationY];
    [newObj setValue:[[NSNumber alloc] initWithFloat:EDGraphDefaultWidth] forKey:EDElementAttributeWidth];
    [newObj setValue:[[NSNumber alloc] initWithFloat:EDGraphDefaultHeight] forKey:EDElementAttributeHeight];
    [newObj setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDElementAttributeSelected];
    return newObj;
}

@end
