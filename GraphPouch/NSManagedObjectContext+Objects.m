//
//  NSManagedObjectContext+Objects.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/2/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "NSManagedObjectContext+Objects.h"

@implementation NSManagedObjectContext (Objects)

- (NSManagedObject*)copyObject:(NSManagedObject*)object toContext:(NSManagedObjectContext*)moc parent:(NSString*)parentEntity
{
    NSString *entityName = [[object entity] name];
    NSMutableDictionary *lookup = [[NSMutableDictionary alloc] init];
    NSManagedObject *newObject = [NSEntityDescription
                                  insertNewObjectForEntityForName:entityName
                                  inManagedObjectContext:moc];
    [lookup setObject:newObject forKey:[object objectID]];
    
    NSArray *attKeys = [[[object entity] attributesByName] allKeys];
    NSDictionary *attributes = [object dictionaryWithValuesForKeys:attKeys];
    
    [newObject setValuesForKeysWithDictionary:attributes];
    
    id oldDestObject = nil;
    id temp = nil;
    NSDictionary *relationships = [[object entity] relationshipsByName];
    for (NSString *key in [relationships allKeys]) {
        
        NSRelationshipDescription *desc = [relationships valueForKey:key];
        NSString *destEntityName = [[desc destinationEntity] name];
        if ([destEntityName isEqualToString:parentEntity]) continue;
        
        if ([desc isToMany]) {
            if ([desc isOrdered]) {
                NSRelationshipDescription *rel = [relationships objectForKey:key];
                NSString *keyName = [rel name];
                // Get a set of all objects in the relationship
                NSMutableOrderedSet *sourceSet = [object mutableOrderedSetValueForKey:keyName];
                NSMutableOrderedSet *clonedSet = [[NSMutableOrderedSet alloc] init];
                for (id relatedObject in sourceSet) {
                    //Clone it, and add clone to set
                    temp = [self copyObject:relatedObject toContext:moc parent:entityName];
                    if (temp) {
                        [clonedSet addObject:temp];
                    }
                }
                [newObject setValue:clonedSet forKey:key];
            }
            else{
                NSMutableSet *newDestSet = [NSMutableSet set];
                
                for (oldDestObject in [object valueForKey:key]) {
                    temp = [lookup objectForKey:[oldDestObject objectID]];
                    if (!temp) {
                        temp = [self copyObject:oldDestObject
                                      toContext:moc
                                         parent:entityName];
                    }
                    [newDestSet addObject:temp];
                }
                
                [newObject setValue:newDestSet forKey:key];
            }
            
        } else {
            oldDestObject = [object valueForKey:key];
            if (!oldDestObject) continue;
            
            temp = [lookup objectForKey:[oldDestObject objectID]];
            if (!temp && ![destEntityName isEqualToString:parentEntity]) {
                temp = [self copyObject:oldDestObject
                              toContext:moc
                                 parent:entityName];
            }
            
            [newObject setValue:temp forKey:key];
        }
    }
    
    return newObject;
}
@end
