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
@dynamic page;
@dynamic points;
@dynamic equations;
@dynamic minValueX;
@dynamic minValueY;
@dynamic maxValueX;
@dynamic maxValueY;

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
        
        EDPoint *newPoint;
        NSSet *points = [aDecoder decodeObjectForKey:EDGraphAttributePoints];
        
        for (EDPoint *point in points){
            // create a point and set it for this graph
            newPoint = [point initWithCoder:aDecoder];
            
            // set relationship
            [self addPointsObject:newPoint];
        }
        
        EDEquation *newEquation;
        NSSet *equations = [aDecoder decodeObjectForKey:EDGraphAttributeEquations];
        
        for (EDEquation *equation in equations){
            newEquation = [equation initWithCoder:aDecoder];
            
            // set relationship
            [self addEquationsObject:newEquation];
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
}
@end
