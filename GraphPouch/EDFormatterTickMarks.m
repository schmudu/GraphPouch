//
//  EDFormatterTickMarks.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDFormatterTickMarks.h"

@implementation EDFormatterTickMarks

-(NSString *) stringForObjectValue:(id)object {
    NSNumber *value = (NSNumber *)object;
    
    if([value boolValue] == FALSE){
        NSLog(@"return false");
        return @"false";
    }
    else {
        NSLog(@"return true");
        return @"true";
    }
}

-(BOOL)getObjectValue: (id*)object forString:string errorDescription:(NSString**)error {
    /*
    NSLog(@"getting object value.");
    if( object ) {
    	return YES;
    }
    return NO;
     */
    return YES;
}

@end
