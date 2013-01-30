//
//  EDPage.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDLine.h"
#import "EDPage.h"
#import "EDGraph.h"
#import "EDPoint.h"
#import "EDEquation.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"

@implementation EDPage

@dynamic currentPage;
@dynamic pageNumber;
@dynamic selected;
@dynamic graphs;
@dynamic lines;

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    // create entity but don't insert it anywhere
    self = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setCurrentPage:[aDecoder decodeBoolForKey:EDPageAttributeCurrent]];
        [self setPageNumber:[[NSNumber alloc] initWithInt:[aDecoder decodeInt32ForKey:EDPageAttributePageNumber]]];
        [self setSelected:[aDecoder decodeBoolForKey:EDPageAttributeSelected]];
        
        
#warning add other elements here
        NSSet *graphs = [aDecoder decodeObjectForKey:EDPageAttributeGraphs];
        for (EDGraph *graph in graphs){
            // set relationship
            [self addGraphsObject:graph];
        }
        
        NSSet *lines = [aDecoder decodeObjectForKey:EDPageAttributeLines];
        for (EDLine *line in lines){
            // set relationship
            [self addLinesObject:line];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:[self currentPage] forKey:EDPageAttributeCurrent];
    [aCoder encodeInt:[[self pageNumber] intValue] forKey:EDPageAttributePageNumber];
    [aCoder encodeBool:[self selected] forKey:EDPageAttributeSelected];
    [aCoder encodeObject:[self graphs] forKey:EDPageAttributeGraphs];
}

#pragma mark pasteboard writing protocol
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    NSArray *writableTypes = nil;
    if (!writableTypes){
        writableTypes = [[NSArray alloc] initWithObjects:EDUTIPage, nil];
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
    return [NSArray arrayWithObject:EDUTIPage];
}

#pragma mark data structure
- (BOOL)containsObject:(NSManagedObject *)object{
    BOOL result = FALSE;
    
    // search through graphs
    for (EDGraph *graph in [self graphs]){
        if ((graph == object) || ([graph containsObject:object])){
            return TRUE;
        }
    }
    return result;
}

+ (NSArray *)allWorksheetClasses{
#warning worksheet elements
    return [NSArray arrayWithObjects:[EDGraph class], [EDLine class], nil];
}
- (NSArray *)getAllWorksheetObjects{
    NSMutableArray *elements = [NSMutableArray array];
    
#warning worksheet elements
    [elements addObjectsFromArray:[[self graphs] allObjects]];
    [elements addObjectsFromArray:[[self lines] allObjects]];
    return elements;
}

- (NSArray *)getAllSelectedWorksheetObjects{
    NSArray *allObjects = [NSMutableArray array];
    allObjects = [self getAllWorksheetObjects];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"selected = %ld", TRUE];
    NSArray *selectedObjects = [allObjects filteredArrayUsingPredicate:searchFilter];;
    
    return selectedObjects;
}
@end
