//
//  EDFormatterNumberTwoDecimal.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/6/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDFormatterNumberTwoDecimal.h"

@implementation EDFormatterNumberTwoDecimal

- (NSString *)stringForObjectValue:(id)obj{
    return [NSString stringWithFormat:@"%.2f", [obj floatValue]];
}

- (BOOL)getObjectValue:(__autoreleasing id *)obj forString:(NSString *)string errorDescription:(NSString *__autoreleasing *)error{
    *obj = [NSNumber numberWithFloat:[string floatValue]];
    return TRUE;
}


@end
