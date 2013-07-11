//
//  NSMutableArray+EDElements.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/10/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "NSMutableArray+EDElements.h"
#import "EDImage.h"
#import "EDExpression.h"
#import "EDGraph.h"
#import "EDLine.h"
#import "EDTextbox.h"

#warning worksheet elements
@implementation NSMutableArray (EDElements)
- (EDExpression *)getAndRemoveObjectExpression{
    // iterate through array and remove first object encountered of type image
    int i = 0;
    for (id obj in self){
        if ([obj isKindOfClass:[EDExpression class]]){
            // remove this object from the array and return it
            [self removeObject:obj];
            return (EDExpression *)obj;
        }
        i++;
    }
    return nil;
}

- (EDGraph *)getAndRemoveObjectGraph{
    // iterate through array and remove first object encountered of type image
    int i = 0;
    for (id obj in self){
        if ([obj isKindOfClass:[EDGraph class]]){
            // remove this object from the array and return it
            [self removeObject:obj];
            return (EDGraph *)obj;
        }
        i++;
    }
    return nil;
}

- (EDImage *)getAndRemoveObjectImage{
    // iterate through array and remove first object encountered of type image
    int i = 0;
    for (id obj in self){
        if ([obj isKindOfClass:[EDImage class]]){
            // remove this object from the array and return it
            [self removeObject:obj];
            return (EDImage *)obj;
        }
        i++;
    }
    return nil;
}

- (EDLine *)getAndRemoveObjectLine{
    // iterate through array and remove first object encountered of type image
    int i = 0;
    for (id obj in self){
        if ([obj isKindOfClass:[EDLine class]]){
            // remove this object from the array and return it
            [self removeObject:obj];
            return (EDLine *)obj;
        }
        i++;
    }
    return nil;
}

- (EDTextbox *)getAndRemoveObjectTextbox{
    // iterate through array and remove first object encountered of type image
    int i = 0;
    for (id obj in self){
        if ([obj isKindOfClass:[EDTextbox class]]){
            // remove this object from the array and return it
            [self removeObject:obj];
            return (EDTextbox *)obj;
        }
        i++;
    }
    return nil;
}
@end
