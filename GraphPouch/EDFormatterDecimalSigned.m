//
//  EDFormatterDecimalSigned.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/11/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDFormatterDecimalSigned.h"

@implementation EDFormatterDecimalSigned

- (NSString *)stringForObjectValue:(id)obj{
    return [NSString stringWithFormat:@"%.2f", [obj floatValue]];
}

- (BOOL)getObjectValue:(__autoreleasing id *)obj forString:(NSString *)string errorDescription:(NSString *__autoreleasing *)error{
    *obj = [NSNumber numberWithFloat:[string floatValue]];
    return TRUE;
}

- (BOOL)isPartialStringValid:(NSString *__autoreleasing *)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString *__autoreleasing *)error{
    NSError *regexError = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(-)?([0-9]*\\.[0-9]{0,2}|[0-9]*)$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&regexError];
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:*partialStringPtr options:0 range:NSMakeRange(0, [*partialStringPtr length])];
    
    if (rangeOfFirstMatch.location != NSNotFound) {
        return TRUE;
    }
    else {
        return FALSE;
    }
}
@end
