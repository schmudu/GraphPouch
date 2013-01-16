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

@interface EDPage : NSManagedObject <NSCoding, NSPasteboardReading, NSPasteboardWriting>

@property BOOL currentPage, selected;
@property (nonatomic, retain) NSNumber *pageNumber;
@property (nonatomic, retain) NSSet *graphs;
- (BOOL)containsObject:(NSManagedObject *)object;
@end

@interface EDPage (CoreDataGeneratedAccessors)
- (void)addGraphsObject:(EDGraph *)value;
- (void)removeGraphsObject:(EDGraph *)value;
- (void)addGraphs:(NSSet *)values;
- (void)removeGraphs:(NSSet *)values;

@end
