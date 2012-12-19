//
//  NSSet+Points.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/9/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSSet+Points.h"
#import "EDPoint.h"

@implementation NSSet (Points)

//- (EDPoint *)findPointByCoordinate:(EDPoint *)matchPoint{
- (EDPoint *)findPoint:(EDPoint *)matchPoint{
    for (EDPoint *point in self){
        if ([matchPoint matchesPoint:point]) {
            return point;
        }
    }
    return nil;
}

- (BOOL)containsPoint:(EDPoint *)matchPoint{
    for (EDPoint *point in self){
        if ([matchPoint matchesPoint:point]) {
            return TRUE;
        }
    }
    return FALSE;
}

/*
- (BOOL)containsPointByCoordinate:(EDPoint *)matchPoint{
    for (EDPoint *point in self){
        if ([matchPoint matchesPointByCoordinate:point]) {
            return TRUE;
        }
    }
    return FALSE;
}*/
@end
