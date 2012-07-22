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
    NSNumber *value = [[NSNumber alloc] initWithInt:GRAPH_INIT_TICK_MARKS];
    [newObj setValue:value forKey:@"hasTickMarks"];
    
    // send notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"sending notification");
    [nc postNotificationName:EDNotificationGraphAdded object:newObj];
    
    return newObj;
}

@end
