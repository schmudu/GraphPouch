//
//  EDPage.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDExpression.h"
#import "EDGraph.h"
#import "EDImage.h"
#import "EDLine.h"
#import "EDPage.h"
#import "EDPoint.h"
#import "EDEquation.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"
#import "EDTextbox.h"

@implementation EDPage

#warning worksheet elements
@dynamic currentPage;
@dynamic expressions;
@dynamic graphs;
@dynamic images;
@dynamic lines;
@dynamic pageNumber;
@dynamic textboxes;
@dynamic selected;

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    // create entity but don't insert it anywhere
    self = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setCurrentPage:[aDecoder decodeBoolForKey:EDPageAttributeCurrent]];
        [self setPageNumber:[[NSNumber alloc] initWithInt:[aDecoder decodeInt32ForKey:EDPageAttributePageNumber]]];
        [self setSelected:[aDecoder decodeBoolForKey:EDPageAttributeSelected]];
        
        
#warning worksheet elements
        NSSet *expressions = [aDecoder decodeObjectForKey:EDPageAttributeExpressions];
        for (EDExpression *expression in expressions){
            // set relationship
            [self addExpressionsObject:expression];
        }
        
        NSSet *graphs = [aDecoder decodeObjectForKey:EDPageAttributeGraphs];
        for (EDGraph *graph in graphs){
            // set relationship
            [self addGraphsObject:graph];
        }
        
        NSSet *images = [aDecoder decodeObjectForKey:EDPageAttributeImages];
        for (EDImage *image in images){
            // set relationship
            [self addImagesObject:image];
        }
        
        NSSet *lines = [aDecoder decodeObjectForKey:EDPageAttributeLines];
        for (EDLine *line in lines){
            // set relationship
            [self addLinesObject:line];
        }
        
        NSSet *textboxes = [aDecoder decodeObjectForKey:EDPageAttributeTextboxes];
        for (EDTextbox *textbox in textboxes){
            // set relationship
            [self addTextboxesObject:textbox];
        }
    }
    return self;
}

- (void)copyAttributes:(EDPage *)source{
    [self setSelected:[source selected]];
    [self setCurrentPage:[source currentPage]];
    [self setPageNumber:[source pageNumber]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:[self currentPage] forKey:EDPageAttributeCurrent];
    [aCoder encodeInt:[[self pageNumber] intValue] forKey:EDPageAttributePageNumber];
    [aCoder encodeBool:[self selected] forKey:EDPageAttributeSelected];
#warning worksheet elements
    [aCoder encodeObject:[self expressions] forKey:EDPageAttributeExpressions];
    [aCoder encodeObject:[self graphs] forKey:EDPageAttributeGraphs];
    [aCoder encodeObject:[self images] forKey:EDPageAttributeImages];
    [aCoder encodeObject:[self lines] forKey:EDPageAttributeLines];
    [aCoder encodeObject:[self textboxes] forKey:EDPageAttributeTextboxes];
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
#warning worksheet elements
    // search through expressions
    for (EDExpression *expression in [self expressions]){
        if (expression == object){
            return TRUE;
        }
    }
    
    for (EDImage *image in [self images]){
        if (image == object){
            return TRUE;
        }
    }
    
    // search through lines
    for (EDLine *line in [self lines]){
        if (line == object){
            return TRUE;
        }
    }
    
    // search through graphs
    for (EDGraph *graph in [self graphs]){
        if ((graph == object) || ([graph containsObject:object])){
            return TRUE;
        }
    }
    
    // search through textboxes
    for (EDTextbox *textbox in [self textboxes]){
        if (textbox == object){
            return TRUE;
        }
    }
    return FALSE;
}

+ (NSArray *)allWorksheetClasses{
#warning worksheet elements
    return [NSArray arrayWithObjects:[EDExpression class], [EDGraph class], [EDImage class], [EDLine class], [EDTextbox class], nil];
}
- (NSArray *)getAllWorksheetObjects{
    NSMutableArray *elements = [NSMutableArray array];
    
#warning worksheet elements
    [elements addObjectsFromArray:[[self expressions] allObjects]];
    [elements addObjectsFromArray:[[self graphs] allObjects]];
    [elements addObjectsFromArray:[[self images] allObjects]];
    [elements addObjectsFromArray:[[self lines] allObjects]];
    [elements addObjectsFromArray:[[self textboxes] allObjects]];
    return elements;
}

- (NSArray *)getAllSelectedWorksheetObjects{
    NSArray *allObjects = [self getAllWorksheetObjects];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"selected = %ld", TRUE];
    NSArray *selectedObjects = [allObjects filteredArrayUsingPredicate:searchFilter];;
    
    return selectedObjects;
}
@end
