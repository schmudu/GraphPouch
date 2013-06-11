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
#import "NSColor+Utilities.h"


@implementation EDEquation

@synthesize matchesHaveSameVisibility;
@synthesize matchesHaveSameLabel;

@dynamic equation;
@dynamic graph;
@dynamic isVisible;
@dynamic showLabel;
@dynamic tokens;
@dynamic equationType;

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[EDEquation alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameEquation inManagedObjectContext:[[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setInequalityAlpha:[aDecoder decodeFloatForKey:EDEquationAttributeInequalityAlpha]];
        [self setInequalityColor:[aDecoder decodeObjectForKey:EDEquationAttributeInequalityColor]];
        [self setEquationType:[aDecoder decodeObjectForKey:EDEquationAttributeType]];
        [self setEquation:[aDecoder decodeObjectForKey:EDEquationAttributeEquation]];
        [self setShowLabel:[aDecoder decodeBoolForKey:EDEquationAttributeShowLabel]];
        [self setIsVisible:[aDecoder decodeBoolForKey:EDEquationAttributeIsVisible]];
        
        //EDToken *newToken;
        NSSet *tokens = [aDecoder decodeObjectForKey:EDEquationAttributeTokens];
        
        for (EDToken *token in tokens){
            // set relationship
            [self addTokensObject:token];
        }
    }
    return self;
}

- (EDEquation *)initWithContext:(NSManagedObjectContext *)context{
    self = [[EDEquation alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameEquation inManagedObjectContext:context] insertIntoManagedObjectContext:nil];
    if (self){
        // init code
        [self setInequalityColor:[NSColor colorWithHexColorString:EDEquationAttributeInequalityColorDefault]];
        [self setInequalityAlpha:EDEquationAttributeInequalityAlphaDefault];
    }
    return self;
}

- (EDEquation *)copy:(NSManagedObjectContext *)context{
    EDEquation *equation = [[EDEquation alloc] initWithContext:context];
    [equation setInequalityAlpha:[self inequalityAlpha]];
    [equation setInequalityColor:[self inequalityColor]];
    [equation setEquationType:[self equationType]];
    [equation setEquation:[self equation]];
    [equation setIsVisible:[self isVisible]];
    [equation setShowLabel:[self showLabel]];
    
    // copy tokens
    EDToken *newToken;
    for (EDToken *token in [self tokens]){
        newToken = [[EDToken alloc] initWithContext:context];
        [context insertObject:newToken];
        [newToken copy:token];
        [equation addTokensObject:newToken];
    }
    return equation;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:[self isVisible] forKey:EDEquationAttributeIsVisible];
    [aCoder encodeBool:[self showLabel] forKey:EDEquationAttributeShowLabel];
    [aCoder encodeObject:[self equation] forKey:EDEquationAttributeEquation];
    [aCoder encodeObject:[self tokens] forKey:EDEquationAttributeTokens];
    [aCoder encodeObject:[self equationType] forKey:EDEquationAttributeType];
    [aCoder encodeFloat:[self inequalityAlpha] forKey:EDEquationAttributeInequalityAlpha];
    [aCoder encodeObject:[self inequalityColor] forKey:EDEquationAttributeInequalityColor];
}

- (void)copyAttributes:(EDEquation *)otherEquation{
    [self setEquation:[otherEquation equation]];
    [self setIsVisible:[otherEquation isVisible]];
    [self setShowLabel:[otherEquation showLabel]];
    [self setEquationType:[otherEquation equationType]];
    [self setInequalityAlpha:[otherEquation inequalityAlpha]];
    [self setInequalityColor:[otherEquation inequalityColor]];
}

- (void)printAllTokens{
    int i=0;
    for (EDToken *token in [self tokens]){
        NSLog(@"i:%d token:%@", i, token);
        i++;
    }
}

- (BOOL)matchesEquation:(EDEquation *)otherEquation{
    if ([[self equation] isEqualToString:[otherEquation equation]])
        return TRUE;
    
    return FALSE;
}

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

#pragma mark pasteboard writing protocol
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    NSArray *writableTypes = nil;
    if (!writableTypes){
        writableTypes = [[NSArray alloc] initWithObjects:EDUTIEquation, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type{
    //return self;
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    return 0;
}

#pragma mark pasteboard reading protocol
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    // encode object
    return NSPasteboardReadingAsKeyedArchive;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard{
    return [NSArray arrayWithObject:EDUTIEquation];
}
@end
