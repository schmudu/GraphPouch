//
//  NSArray+Utilities.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/5/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSMutableArray+EDPoint.h"
#import "EDPoint.h"

@implementation NSMutableArray (EDPoint)


- (BOOL)containsPointByCoordinate:(EDPoint *)point{
    // iterate through dictionary
    for (EDPoint *currentPoint in self){
        // if both points match, then return true
        if ([currentPoint matchesPointByCoordinate:point]){
            return TRUE;
        } 
    }
    return FALSE;
}

- (BOOL)containsPoint:(EDPoint *)point{
    // iterate through dictionary
    for (EDPoint *currentPoint in self){
        // if both points match, then return true
        if ([currentPoint matchesPoint:point]){
            return TRUE;
        } 
    }
    return FALSE;
}

- (void)removePoint:(EDPoint *)point{
    NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
    // iterate through dictionary
    for (EDPoint *currentPoint in self){
        // if both points match, then remove point
        if ([currentPoint matchesPoint:point]){
            [removeObjects addObject:currentPoint];
        } 
    }
    
    // remove all objects in remove objects
    for (EDPoint *removePoint in removeObjects){
        [self removeObject:removePoint];
    }
}

- (void)removePointByCoordinate:(EDPoint *)point{
    NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
    // iterate through dictionary
    for (EDPoint *currentPoint in self){
        // if both points match, then remove point
        if ([currentPoint matchesPointByCoordinate:point]){
            [removeObjects addObject:currentPoint];
        } 
    }
    
    // remove all objects in remove objects
    for (EDPoint *removePoint in removeObjects){
        [self removeObject:removePoint];
    }
}
@end
