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
    
    // Init ticks marks to default
    //NSNumber *value = [[NSNumber alloc] initWithInt:FALSE];
    NSNumber *value = [[NSNumber alloc] initWithInt:GRAPH_INIT_TICK_MARKS];
    [newObj setValue:value forKey:@"hasTickMarks"];
    return newObj;
}

@end
