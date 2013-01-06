//
//  EDEquation.h
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EDGraph, EDToken;

@interface EDEquation : NSManagedObject <NSCoding, NSPasteboardReading, NSPasteboardReading>

@property (nonatomic, retain) NSString * equation;
@property BOOL isVisible;
@property BOOL showLabel;
@property BOOL matchesHaveSameVisibility;
@property BOOL matchesHaveSameLabel;
@property (nonatomic, retain) EDGraph *graph;
@property (nonatomic, retain) NSOrderedSet *tokens;

- (void)printAllTokens;
- (BOOL)matchesEquation:(EDEquation *)otherEquation;
- (void)copyAttributes:(EDEquation *)otherEquation;
@end

@interface EDEquation (CoreDataGeneratedAccessors)

- (EDEquation *)initWithContext:(NSManagedObjectContext *)context;
- (EDEquation *)copy;
- (void)insertObject:(EDToken *)value inTokensAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTokensAtIndex:(NSUInteger)idx;
- (void)insertTokens:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTokensAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTokensAtIndex:(NSUInteger)idx withObject:(EDToken *)value;
- (void)replaceTokensAtIndexes:(NSIndexSet *)indexes withTokens:(NSArray *)values;
- (void)addTokensObject:(EDToken *)value;
- (void)removeTokensObject:(EDToken *)value;
- (void)addTokens:(NSOrderedSet *)values;
- (void)removeTokens:(NSOrderedSet *)values;
- (void)removeAllTokens;
@end
