//
//  EDGraph.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraph.h"
#import "EDToken.h"
#import "EDPage.h"
#import "EDPoint.h"
#import "EDEquation.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"
#import "NSManagedObject+EasyFetching.h"

@implementation EDGraph

@dynamic hasCoordinateAxes;
@dynamic hasGridLines;
@dynamic hasTickMarks;
@dynamic hasLabels;
@dynamic points;
@dynamic page;
@dynamic equations;
@dynamic minValueX;
@dynamic minValueY;
@dynamic maxValueX;
@dynamic maxValueY;
@dynamic scaleX;
@dynamic scaleY;
@dynamic labelIntervalX;
@dynamic labelIntervalY;


- (EDGraph *)initWithContext:(NSManagedObjectContext *)context{
    self = [[EDGraph alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:context] insertIntoManagedObjectContext:nil];
    if (self){
        // init code
    }
    return self;
}

- (void)copyAttributes:(EDElement *)source{
    [super copyAttributes:source];
    
    [self setHasCoordinateAxes:[(EDGraph *)source hasCoordinateAxes]];
    [self setHasGridLines:[(EDGraph *)source hasGridLines]];
    [self setHasLabels:[(EDGraph *)source hasLabels]];
    [self setHasTickMarks:[(EDGraph *)source hasTickMarks]];
    [self setMinValueX:[(EDGraph *)source minValueX]];
    [self setMinValueY:[(EDGraph *)source minValueY]];
    [self setMaxValueX:[(EDGraph *)source maxValueX]];
    [self setMaxValueY:[(EDGraph *)source maxValueY]];
    [self setScaleX:[(EDGraph *)source scaleX]];
    [self setScaleY:[(EDGraph *)source scaleY]];
    [self setLabelIntervalX:[(EDGraph *)source labelIntervalX]];
    [self setLabelIntervalY:[(EDGraph *)source labelIntervalY]];
}

- (EDGraph *)copy:(NSManagedObjectContext *)context{
    EDGraph *graph = [[EDGraph alloc] initWithContext:context];
    [graph copyAttributes:self];
    
    // copy points
    for (EDPoint *point in [self points]){
        [graph addPointsObject:point];
    }
    
    // copy equations
    for (EDEquation *equation in [self equations]){
        [graph addEquationsObject:equation];
    }
    return graph;
}

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    // create entity but don't insert it anywhere
    self = [[EDGraph alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameGraph inManagedObjectContext:[[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setHasLabels:[aDecoder decodeBoolForKey:EDGraphAttributeLabels]];
        [self setHasGridLines:[aDecoder decodeBoolForKey:EDGraphAttributeGridLines]];
        [self setHasTickMarks:[aDecoder decodeBoolForKey:EDGraphAttributeTickMarks]];
        [self setHasCoordinateAxes:[aDecoder decodeBoolForKey:EDGraphAttributeCoordinateAxes]];
        [self setSelected:[aDecoder decodeBoolForKey:EDElementAttributeSelected]];
        [self setLocationX:[aDecoder decodeFloatForKey:EDElementAttributeLocationX]];
        [self setLocationY:[aDecoder decodeFloatForKey:EDElementAttributeLocationY]];
        [self setElementWidth:[aDecoder decodeFloatForKey:EDElementAttributeWidth]];
        [self setElementHeight:[aDecoder decodeFloatForKey:EDElementAttributeHeight]];
        [self setScaleX:[aDecoder decodeObjectForKey:EDGraphAttributeScaleX]];
        [self setScaleY:[aDecoder decodeObjectForKey:EDGraphAttributeScaleY]];
        [self setLabelIntervalX:[aDecoder decodeObjectForKey:EDGraphAttributeLabelIntervalX]];
        [self setLabelIntervalY:[aDecoder decodeObjectForKey:EDGraphAttributeLabelIntervalY]];
        [self setMaxValueX:[aDecoder decodeObjectForKey:EDGraphAttributeMaxValueX]];
        [self setMinValueX:[aDecoder decodeObjectForKey:EDGraphAttributeMinValueX]];
        [self setMaxValueY:[aDecoder decodeObjectForKey:EDGraphAttributeMaxValueY]];
        [self setMinValueY:[aDecoder decodeObjectForKey:EDGraphAttributeMinValueY]];
        [self setZIndex:[aDecoder decodeObjectForKey:EDElementAttributeZIndex]];
        
        //EDPoint *newPoint;
        NSSet *points = [aDecoder decodeObjectForKey:EDGraphAttributePoints];
        
        for (EDPoint *point in points){
            // set relationship
            [self addPointsObject:point];
        }
        
        //EDEquation *newEquation;
        NSSet *equations = [aDecoder decodeObjectForKey:EDGraphAttributeEquations];
        
        for (EDEquation *equation in equations){
            // set relationship
            [self addEquationsObject:equation];
            
            NSOrderedSet *tokens = [equation tokens];
        
            for (EDToken *token in tokens){
                // set relationship
                [equation addTokensObject:token];
            }
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:[self hasLabels] forKey:EDGraphAttributeLabels];
    [aCoder encodeBool:[self hasGridLines] forKey:EDGraphAttributeGridLines];
    [aCoder encodeBool:[self hasTickMarks] forKey:EDGraphAttributeTickMarks];
    [aCoder encodeBool:[self hasCoordinateAxes] forKey:EDGraphAttributeCoordinateAxes];
    [aCoder encodeBool:[self selected] forKey:EDElementAttributeSelected];
    [aCoder encodeFloat:[self locationX] forKey:EDElementAttributeLocationX];
    [aCoder encodeFloat:[self locationY] forKey:EDElementAttributeLocationY];
    [aCoder encodeFloat:[self elementWidth] forKey:EDElementAttributeWidth];
    [aCoder encodeFloat:[self elementHeight] forKey:EDElementAttributeHeight];
    [aCoder encodeObject:[self points] forKey:EDGraphAttributePoints];
    [aCoder encodeObject:[self equations] forKey:EDGraphAttributeEquations];
    [aCoder encodeObject:[self scaleX] forKey:EDGraphAttributeScaleX];
    [aCoder encodeObject:[self scaleY] forKey:EDGraphAttributeScaleY];
    [aCoder encodeObject:[self labelIntervalX] forKey:EDGraphAttributeLabelIntervalX];
    [aCoder encodeObject:[self labelIntervalY] forKey:EDGraphAttributeLabelIntervalY];
    [aCoder encodeObject:[self maxValueX] forKey:EDGraphAttributeMaxValueX];
    [aCoder encodeObject:[self minValueX] forKey:EDGraphAttributeMinValueX];
    [aCoder encodeObject:[self maxValueY] forKey:EDGraphAttributeMaxValueY];
    [aCoder encodeObject:[self minValueY] forKey:EDGraphAttributeMinValueY];
    [aCoder encodeObject:[self zIndex] forKey:EDElementAttributeZIndex];
}


#pragma mark pasteboard writing protocol
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    NSArray *writableTypes = nil;
    if (!writableTypes){
        writableTypes = [[NSArray alloc] initWithObjects:EDUTIGraph, nil];
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
    return [NSArray arrayWithObject:EDUTIGraph];
}

#pragma mark data structure
- (BOOL)containsObject:(NSManagedObject *)object{
    BOOL result = FALSE;
    
    // search through points
    for (EDPoint *point in [self points]){
        if (point == object)
            return TRUE;
    }
    
    // search through equations
    for (EDEquation *equation in [self equations]){
        if (equation == object)
            return TRUE;
    }
    return result;
}
@end
