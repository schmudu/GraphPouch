//
//  EDGraphArrayController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraphArrayController.h"

@implementation EDGraphArrayController

- (id)newObject{
    NSLog(@"creating new object...");
    id newObj = [super newObject];
    NSNumber *value = [[NSNumber alloc] initWithInt:FALSE];
    [newObj setValue:value forKey:@"hasTickMarks"];
    //[newObj setValue:@"something" forKey:@"hasTickMarks"];
    //NSLog(@"value for tick mark:%d", (NSNumber *)[newObj valueForKey:@"hasTickMarks"]);
    return newObj;
}

@end
