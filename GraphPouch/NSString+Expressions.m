//
//  NSString+Expressions.m
//  GraphPouch
//
//  Created by PATRICK LEE on 6/21/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "NSString+Expressions.h"

@implementation NSString (Expressions)

- (EDExpressionEqualityType)expressionEqualityType{
    NSError *regexError = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"=" options:NSCaseInsensitiveSearch error:&regexError];
    
    // go through all signs, there can be only one per expression
    if ([regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])]){
        return EDExpressionEqualityTypeEqual;
    }
    else{
        regex = [NSRegularExpression regularExpressionWithPattern:@">" options:NSCaseInsensitiveSearch error:&regexError];
        if ([regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])]){
            return EDExpressionEqualityTypeGreaterThan;
        }
        else{
            regex = [NSRegularExpression regularExpressionWithPattern:@"≥" options:NSCaseInsensitiveSearch error:&regexError];
            if ([regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])]){
                return EDExpressionEqualityTypeGreaterThanOrEqual;
            }
            else{
                regex = [NSRegularExpression regularExpressionWithPattern:@"<" options:NSCaseInsensitiveSearch error:&regexError];
                if ([regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])]){
                    return EDExpressionEqualityTypeLessThan;
                }
                else{
                    regex = [NSRegularExpression regularExpressionWithPattern:@"≤" options:NSCaseInsensitiveSearch error:&regexError];
                    if ([regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])]){
                        return EDExpressionEqualityTypeLessThanOrEqual;
                    }
                }
            }
        }
    }
    return EDExpressionEqualityTypeNone;
}
@end
