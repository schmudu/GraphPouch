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

- (void)copyAttributes:(EDEquation *)otherEquation{
    [self setEquation:[otherEquation equation]];
    [self setIsVisible:[otherEquation isVisible]];
    [self setShowLabel:[otherEquation showLabel]];
    [self setGraph:[otherEquation graph]];
    
    // clear tokens
    [otherEquation removeAllTokens];
    
    // copy this equation's tokens
    EDToken *tokenCopy;
    for (EDToken *token in [self tokens]){
        // copy token
        tokenCopy = [token copy:[self managedObjectContext]];
        
        // add to equation
        [otherEquation addTokensObject:tokenCopy];
    }
}

- (void)printAllTokens{
    int i=0;
    for (EDToken *token in [self tokens]){
        NSLog(@"i:%d token:%@", i, token);
        i++;
    }
}

- (BOOL)matchesEquation:(EDEquation *)otherEquation{
    // enumerate tokens and if value is the same then same equation
    EDToken *otherEquationToken, *thisToken;
    int i = 0;
    
    // if every token matches then we have a match
    while (i < [[self tokens] count]){
        thisToken = [[self tokens] objectAtIndex:i];
        otherEquationToken = [[otherEquation tokens] objectAtIndex:i];
        
        if (![[thisToken value] isEqualToString:[otherEquationToken value]]) {
            return FALSE;
        }
        i++;
    }
    return TRUE;
}

/*
- (void)addTokensObject:(EDToken *)value{
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self tokens]];
    [tempSet addObject:value];
    [self setTokens:tempSet];
}*/

#pragma mark stackoverflow
static NSString *const kItemsKey = @"tokens";
- (void)removeAllTokens{
    for (EDToken *token in [self tokens]){
        // delete relationship
        [token setEquation:nil];
        
        // remove from context
        [[self managedObjectContext] deleteObject:token];
    }
}

- (void)insertObject:(EDToken *)value inTokensAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)removeObjectFromTokensAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)insertTokens:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)removeTokensAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)replaceObjectInTokensAtIndex:(NSUInteger)idx withObject:(EDToken *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)replaceTokensAtIndexes:(NSIndexSet *)indexes withTokens:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)addTokensObject:(EDToken *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)removeTokensObject:(EDToken *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    }
}

- (void)addTokens:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    }
}

- (void)removeTokens:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    }
}
@end
