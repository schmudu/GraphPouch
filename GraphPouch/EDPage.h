//
//  EDPage.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EDGraph;
@class EDLine;
@class EDTextbox;

@interface EDPage : NSManagedObject <NSCoding, NSPasteboardReading, NSPasteboardWriting>

@property BOOL currentPage, selected;
@property (nonatomic, retain) NSNumber *pageNumber;
@property (nonatomic, retain) NSSet *graphs;
@property (nonatomic, retain) NSSet *lines;
@property (nonatomic, retain) NSSet *textboxes;
- (BOOL)containsObject:(NSManagedObject *)object;
- (NSArray *)getAllWorksheetObjects;
- (NSArray *)getAllSelectedWorksheetObjects;
+ (NSArray *)allWorksheetClasses;
@end

@interface EDPage (CoreDataGeneratedAccessors)
#warning worksheet elements
- (void)addGraphsObject:(EDGraph *)value;
- (void)removeGraphsObject:(EDGraph *)value;
- (void)addGraphs:(NSSet *)values;
- (void)removeGraphs:(NSSet *)values;

- (void)addLinesObject:(EDLine *)value;
- (void)removeLinesObject:(EDLine *)value;
- (void)addLines:(NSSet *)values;
- (void)removeLines:(NSSet *)values;

- (void)addTextboxesObject:(EDTextbox *)value;
- (void)removeTextboxesObject:(EDTextbox *)value;
- (void)addTextboxes:(NSSet *)values;
- (void)removeTextboxes:(NSSet *)values;

@end
