//
//  NSArray+Utilities.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/5/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSMutableArray+Utilities.h"
#import "EDPoint.h"

@implementation NSMutableArray (Utilities)


- (BOOL)containsPoint:(EDPoint *)point{
    // iterate through dictionary
    for (EDPoint *currentPoint in self){
        //currentPoint = [self objectForKey:key];
        
        // if both points match, then return true
        if (([point locationX] == [currentPoint locationX]) && ([point locationY] == [currentPoint locationY])) {
            return TRUE;
        } 
    }
    return FALSE;
}

- (void)removePoint:(EDPoint *)point{
    NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
    //EDPoint *currentPoint;
    // iterate through dictionary
    //for (id key in self){
    for (EDPoint *currentPoint in self){
        //currentPoint = [self objectForKey:key];
        
        // if both points match, then remove point
        if (([point locationX] == [currentPoint locationX]) && ([point locationY] == [currentPoint locationY])) {
            [removeObjects addObject:currentPoint];
            // remove point
            //[self removeObjectForKey:key];
        } 
    }
    
    // remove all objects in remove objects
    for (EDPoint *removePoint in removeObjects){
        [self removeObject:removePoint];
    }
}
@end
