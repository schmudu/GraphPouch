//
//  EDGraph.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraph.h"
#import "EDConstants.h"
#import "NSManagedObject+EasyFetching.h"
#import "EDCoreDataUtility.h"

@implementation EDGraph

@dynamic equation, hasGridLines, hasTickMarks, hasCoordinateAxes, page;

#pragma mark encoding, decoding this object

- (id)initWithCoder:(NSCoder *)aDecoder{
    // create entity but don't insert it anywhere
    self = [[EDGraph alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setEquation:[aDecoder decodeObjectForKey:EDGraphAttributeEquation]];
        [self setHasGridLines:[aDecoder decodeBoolForKey:EDGraphAttributeGrideLines]];
        [self setHasTickMarks:[aDecoder decodeBoolForKey:EDGraphAttributeTickMarks]];
        [self setHasCoordinateAxes:[aDecoder decodeBoolForKey:EDGraphAttributeCoordinateAxes]];
        [self setSelected:[aDecoder decodeBoolForKey:EDElementAttributeSelected]];
        [self setLocationX:[aDecoder decodeFloatForKey:EDElementAttributeLocationX]];
        [self setLocationY:[aDecoder decodeFloatForKey:EDElementAttributeLocationY]];
        [self setElementWidth:[aDecoder decodeFloatForKey:EDElementAttributeWidth]];
        //[self setPage:[aDecoder decodeObjectForKey:EDGraphAttributePage]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[self equation] forKey:EDGraphAttributeEquation];
    [aCoder encodeBool:[self hasGridLines] forKey:EDGraphAttributeGrideLines];
    [aCoder encodeBool:[self hasTickMarks] forKey:EDGraphAttributeTickMarks];
    [aCoder encodeBool:[self hasCoordinateAxes] forKey:EDGraphAttributeCoordinateAxes];
    [aCoder encodeBool:[self selected] forKey:EDElementAttributeSelected];
    [aCoder encodeFloat:[self locationX] forKey:EDElementAttributeLocationX];
    [aCoder encodeFloat:[self locationY] forKey:EDElementAttributeLocationY];
    [aCoder encodeFloat:[self elementWidth] forKey:EDElementAttributeWidth];
    [aCoder encodeFloat:[self elementHeight] forKey:EDElementAttributeHeight];
    //[aCoder encodeObject:[self page] forKey:EDGraphAttributePage];
}
@end
