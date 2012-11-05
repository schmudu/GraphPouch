//
//  NSMutableDictionary+Utilities.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/24/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSMutableDictionary+Utilities.h"

@implementation NSMutableDictionary (Utilities)

- (id)findKeyinDictionaryForValue:(id)value{
    for (NSObject *key in self){
        NSLog(@"key:%@ value:%@", [[NSValue valueWithNonretainedObject:key] nonretainedObjectValue], [self objectForKey:key]);
    }
    return nil;
}

- (BOOL)containsPoint:(EDPoint *)point{
    EDPoint *currentPoint;
    // iterate through dictionary
    for (id key in self){
        currentPoint = [self objectForKey:key];
        
        // if both points match, then return true
        if (([point locationX] == [currentPoint locationX]) && ([point locationY] == [currentPoint locationY])) {
            return TRUE;
        } 
    }
    return FALSE;
}

- (void)removePoint:(EDPoint *)point{
    EDPoint *currentPoint;
    // iterate through dictionary
    for (id key in self){
        currentPoint = [self objectForKey:key];
        
        // if both points match, then remove point
        if (([point locationX] == [currentPoint locationX]) && ([point locationY] == [currentPoint locationY])) {
            // remove point
            [self removeObjectForKey:key];
        } 
    }
}
@end
