//
//  NSMutableDictionary+Utilities.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/24/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSMutableDictionary+Utilities.h"

@implementation NSMutableDictionary (Utilities)

- (id)findKeyinDictionaryForValue:(id)value{
    for (NSObject *key in self){
        NSLog(@"key:%@ value:%@", [[NSValue valueWithNonretainedObject:key] nonretainedObjectValue], [self objectForKey:key]);
    }
    return nil;
}
@end
