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

@dynamic equation, hasGridLines, hasTickMarks;

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    // create entity but don't insert it anywhere
    self = [[EDGraph alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setEquation:[[aDecoder decodeObjectForKey:EDGraphAttributeEquation] string]];
        [self setHasGridLines:[aDecoder decodeBoolForKey:EDGraphAttributeGrideLines]];
        [self setHasTickMarks:[aDecoder decodeBoolForKey:EDGraphAttributeTickMarks]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[self equation] forKey:EDGraphAttributeEquation];
    [aCoder encodeBool:[self hasGridLines] forKey:EDGraphAttributeGrideLines];
    [aCoder encodeBool:[self hasTickMarks] forKey:EDGraphAttributeTickMarks];
}
@end
