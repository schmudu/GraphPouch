//
//  EDEquation.m
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDEquation.h"
#import "EDGraph.h"
#import "EDToken.h"
#import "EDConstants.h"


@implementation EDEquation

@dynamic equation;
@dynamic isVisible;
@dynamic showLabel;
@dynamic graph;
@dynamic tokens;

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[EDEquation alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameEquation inManagedObjectContext:[self managedObjectContext]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setEquation:[aDecoder decodeObjectForKey:EDEquationAttributeEquation]];
        [self setShowLabel:[aDecoder decodeBoolForKey:EDEquationAttributeShowLabel]];
        [self setIsVisible:[aDecoder decodeBoolForKey:EDEquationAttributeIsVisible]];
        
        EDToken *newToken;
        NSSet *tokens = [aDecoder decodeObjectForKey:EDEquationAttributeTokens];
        
        for (EDToken *token in tokens){
            // create a point and set it for this graph
            newToken = [token initWithCoder:aDecoder];
            
            // set relationship
            [self addTokensObject:newToken];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:[self isVisible] forKey:EDEquationAttributeIsVisible];
    [aCoder encodeBool:[self showLabel] forKey:EDEquationAttributeShowLabel];
    [aCoder encodeObject:[self equation] forKey:EDEquationAttributeEquation];
    [aCoder encodeObject:[self tokens] forKey:EDEquationAttributeTokens];
}

- (void)printAllTokens{
    int i=0;
    for (EDToken *token in [self tokens]){
        NSLog(@"i:%d token:%@", i, token);
        i++;
    }
}

- (void)addTokensObject:(EDToken *)value{
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self tokens]];
    [tempSet addObject:value];
    [self setTokens:tempSet];
}
@end
