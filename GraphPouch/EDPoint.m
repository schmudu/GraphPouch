//
//  EDPoint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPoint.h"
#import "EDGraph.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"

@implementation EDPoint

@synthesize matchesHaveSameVisibility;
@synthesize matchesHaveSameLabel;

@dynamic locationX;
@dynamic isVisible;
@dynamic showLabel;
@dynamic locationY;
@dynamic graph;

- (id)initWithCoder:(NSCoder *)aDecoder{
    // create entity but don't insert it anywhere
    self = [[EDPoint alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePoint inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setIsVisible:[aDecoder decodeBoolForKey:EDGraphPointAttributeVisible]];
        [self setShowLabel:[aDecoder decodeBoolForKey:EDGraphPointAttributeShowLabel]];
        [self setLocationX:[aDecoder decodeFloatForKey:EDElementAttributeLocationX]];
        [self setLocationY:[aDecoder decodeFloatForKey:EDElementAttributeLocationY]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:[self isVisible] forKey:EDGraphPointAttributeVisible];
    [aCoder encodeBool:[self isVisible] forKey:EDGraphPointAttributeShowLabel];
    [aCoder encodeFloat:[self locationX] forKey:EDElementAttributeLocationX];
    [aCoder encodeFloat:[self locationY] forKey:EDElementAttributeLocationY];
}

- (BOOL)matchesPoint:(EDPoint *)otherPoint{
    if (([self locationX] == [otherPoint locationX]) 
        && ([self locationY] == [otherPoint locationY]) 
        && ([self isVisible] == [otherPoint isVisible])
        && ([self showLabel] == [otherPoint showLabel])){
            return TRUE;
    }
    return FALSE;
}

- (BOOL)matchesPointByCoordinate:(EDPoint *)otherPoint{
    if (([self locationX] == [otherPoint locationX]) && ([self locationY] == [otherPoint locationY])){
        return TRUE;
    }
    return FALSE;
}

- (void)copyAttributes:(EDPoint *)otherPoint{
    [self setShowLabel:[otherPoint showLabel]];
    [self setIsVisible:[otherPoint isVisible]];
    [self setLocationX:[otherPoint locationX]];
    [self setLocationY:[otherPoint locationY]];
}

- (id)copyWithZone:(NSZone *)zone{
    id copy = [[EDPoint alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePoint inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:nil];
    if (copy) 
    {
        // Copy NSObject subclasses
        /*
        [copy setLocationX:[self locationX]];
        [copy setLocationY:[self locationY]];
        [copy setIsVisible:[self isVisible]];
         */
        [copy setLocationX:0];
        [copy setLocationY:0];
        [copy setIsVisible:TRUE];
        [copy setShowLabel:TRUE];
    }
    
    return copy;
}

@end
