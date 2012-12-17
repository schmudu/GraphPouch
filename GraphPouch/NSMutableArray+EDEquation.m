//
//  NSMutableArray+EDEquation.m
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSMutableArray+EDEquation.h"
#import "EDEquation.h"

@implementation NSMutableArray (EDEquation)

- (BOOL)containsEquation:(EDEquation *)equation{
    // iterate through dictionary
    for (EDEquation *currentEquation in self){
        // if both points match, then return true
        if ([currentEquation matchesEquation:equation]){
            return TRUE;
        } 
    }
    return FALSE;
}

- (void)removeEquation:(EDEquation *)equation{
    NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
    // iterate through dictionary
    for (EDEquation *currentEquation in self){
        // if both points match, then remove point
        if ([currentEquation matchesEquation:equation]){
            [removeObjects addObject:currentEquation];
        } 
    }
    
    // remove all objects in remove objects
    for (EDEquation *removeEquation in removeObjects){
        [self removeObject:removeEquation];
    }
}
@end
