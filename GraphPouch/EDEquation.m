//
//  EDEquation.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDEquation.h"
#import "EDGraph.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"

@implementation EDEquation

@dynamic equation;
@dynamic showLabel;
@dynamic isVisible;
@dynamic graph;

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[EDEquation alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameEquation inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]];
    if(self){
        [self setEquation:[aDecoder decodeObjectForKey:EDEquationAttributeEquation]];
        [self setShowLabel:[aDecoder decodeBoolForKey:EDEquationAttributeShowLabel]];
        [self setIsVisible:[aDecoder decodeBoolForKey:EDEquationAttributeIsVisible]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:[self isVisible] forKey:EDEquationAttributeIsVisible];
    [aCoder encodeBool:[self showLabel] forKey:EDEquationAttributeShowLabel];
    [aCoder encodeObject:[self equation] forKey:EDEquationAttributeEquation];
}
@end
