//
//  EDFormatterEquation.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/13/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDFormatterEquation.h"

@implementation EDFormatterEquation
- (NSString *)stringForObjectValue:(id)obj{
    return [NSString stringWithFormat:@"%@", obj];
}

- (BOOL)getObjectValue:(__autoreleasing id *)obj forString:(NSString *)string errorDescription:(NSString *__autoreleasing *)error{
    *obj = [[NSString alloc] initWithFormat:@"%@", string];
    return TRUE;
}

- (BOOL)isPartialStringValid:(NSString *__autoreleasing *)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString *__autoreleasing *)error{
    NSError *regexError = NULL;
    // regular expression for the following items
    // numbers (negative, unsigned, signed, decimal form
    // trigonometric functions
    // powers
    // operators
    // variables
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(|[0-9]|\\.|s|i|n|c|o|s|t|a|\\^|\\+|\\-|\\*|\\/|x|y)*$"
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
