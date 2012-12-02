//
//  EDTokenizer.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDTokenizer.h"
#import "EDToken.h"
#import <regex.h>
#import "EDConstants.h"

@implementation EDTokenizer

+ (NSMutableArray *)tokenize:(NSString *)str error:(NSError **)error{
    NSMutableDictionary *errorDictionary = [[NSMutableDictionary alloc] init];
    [errorDictionary setValue:@"some error" forKey:NSLocalizedDescriptionKey];
    *error = [[NSError alloc] initWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDictionary];
    return nil;
}

+ (BOOL)isValidToken:(EDToken *)token{
    regex_t regex;
    int reti;
    NSString *str = [[NSString alloc] initWithString:[token value]];
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    
    // numbers
    reti = regcomp(&regex, "^[0-9]+$", REG_EXTENDED);
    if (reti) 
        return FALSE;
    reti = regexec(&regex, cStr, 0, NULL, 0);
    if (!reti) {
        // set type to number
        [token setType:EDTokenTypeNumber];
        return TRUE;
    }
    return FALSE;
}

@end