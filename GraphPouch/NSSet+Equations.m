//
//  NSSet+Equations.m
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSSet+Equations.h"
#import "EDEquation.h"

@implementation NSSet (Equations)

- (EDEquation *)findEquation:(EDEquation *)matchEquation{
    for (EDEquation *equation in self){
        if ([matchEquation matchesEquation:equation]) {
            return equation;
        }
    }
    return nil;
}

- (BOOL)containsEquation:(EDEquation *)matchEquation{
    for (EDEquation *equation in self){
        if ([matchEquation matchesEquation:equation]) {
            return TRUE;
        }
    }
    return FALSE;
}
@end
