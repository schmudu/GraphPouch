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

@interface EDEquation : NSManagedObject <NSCoding>

@property (nonatomic, retain) NSString * equation;
@property BOOL isVisible;
@property BOOL showLabel;
@property (nonatomic, retain) EDGraph *graph;
@property (nonatomic, retain) NSOrderedSet *tokens;

- (void)printAllTokens;
@end

@interface EDEquation (CoreDataGeneratedAccessors)

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
@end
