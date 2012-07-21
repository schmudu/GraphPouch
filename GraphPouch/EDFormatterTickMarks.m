//
//  EDFormatterTickMarks.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDFormatterTickMarks.h"

@implementation EDFormatterTickMarks

/*
- (NSString *)stringForObjectValue:(id)obj{
    NSLog(@"object in column: %@", obj);
    NSString *returnStr = [[NSString alloc] initWithFormat:@"hello"];
    return returnStr;
}*/
-(NSString *) stringForObjectValue:(id)object {
    NSNumber *value = (NSNumber *)object;
    //NSLog(@"object: %@", object);
    //NSLog(@"equal: %d bool: %d object:%@", (value == FALSE), [value boolValue], object);
    //NSLog(@"number: %@ value: %d equal?:%d", object, [value boolValue], ([value boolValue] == TRUE));
    /*
    if(![object isKindOfClass: [ NSString class ] ] ) {
    	return nil;
    }*/
    //return [NSString stringWithFormat:@"hello"];
    if([value boolValue] == FALSE){
        NSLog(@"return false");
        return @"false";
    }
    else {
        NSLog(@"return true");
        return @"true";
    }
    //return returnStr;
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
