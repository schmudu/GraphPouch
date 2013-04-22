//
//  EDPage.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EDExpression;
@class EDGraph;
@class EDImage;
@class EDLine;
@class EDTextbox;

@interface EDPage : NSManagedObject <NSCoding, NSPasteboardReading, NSPasteboardWriting>

@property BOOL currentPage, selected;
@property (nonatomic, retain) NSNumber *pageNumber;
@property (nonatomic, retain) NSSet *expressions;
@property (nonatomic, retain) NSSet *graphs;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *lines;
@property (nonatomic, retain) NSSet *textboxes;
- (BOOL)containsObject:(NSManagedObject *)object;
- (NSArray *)getAllWorksheetObjects;
- (NSArray *)getAllSelectedWorksheetObjects;
+ (NSArray *)allWorksheetClasses;
- (void)copyAttributes:(EDPage *)source;
@end

@interface EDPage (CoreDataGeneratedAccessors)
#warning worksheet elements
- (void)addExpressionsObject:(EDExpression *)value;
- (void)removeExpressionsObject:(EDExpression *)value;
- (void)addExpressions:(NSSet *)values;
- (void)removeExpressions:(NSSet *)values;

- (void)addGraphsObject:(EDGraph *)value;
- (void)removeGraphsObject:(EDGraph *)value;
- (void)addGraphs:(NSSet *)values;
- (void)removeGraphs:(NSSet *)values;

- (void)addImagesObject:(EDImage *)value;
- (void)removeImagesObject:(EDImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addLinesObject:(EDLine *)value;
- (void)removeLinesObject:(EDLine *)value;
- (void)addLines:(NSSet *)values;
- (void)removeLines:(NSSet *)values;

- (void)addTextboxesObject:(EDTextbox *)value;
- (void)removeTextboxesObject:(EDTextbox *)value;
- (void)addTextboxes:(NSSet *)values;
- (void)removeTextboxes:(NSSet *)values;


@end
