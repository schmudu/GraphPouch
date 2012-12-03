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
#import "EDScanner.h"
#import "EDStack.h"

@implementation EDTokenizer

+ (EDStack *)tokenize:(NSString *)str error:(NSError **)error{
    int i = 0;
    NSString *currentChar;
    EDToken *currentToken, *potentialToken;
    EDStack *tokenStack = [[EDStack alloc] init];
    currentToken = [[EDToken alloc] init];
    
    // read in equation
    [EDScanner scanString:str];
    
    while (i<[str length]){
        // get current character
        currentChar = [EDScanner currentChar];
        
        // append chracter
        [currentToken appendChar:currentChar];
        
        if ([EDTokenizer isValidToken:currentToken]) {
            // save token
            potentialToken = [currentToken copy];
            
            // increment scanner
            [EDScanner increment];
            i++;
        }
        else {
            if (potentialToken) {
                // push last valid token
                EDToken *newToken = [potentialToken copy];
                [tokenStack push:newToken];
                
                // release potential token
                potentialToken = nil;
                
                // create new token
                currentToken = [[EDToken alloc] init];
            }
            else{
                NSMutableDictionary *errorDictionary = [[NSMutableDictionary alloc] init];
                [errorDictionary setValue:[[NSString alloc] initWithFormat:@"Could not recognize character at position:%d",i+1] forKey:NSLocalizedDescriptionKey];
                *error = [[NSError alloc] initWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDictionary];
                return nil;
            }
        }
    }
    
    if (potentialToken){
        // add last token
        [tokenStack push:potentialToken];
        return tokenStack;
    }
    else {
        if ([tokenStack count] > 0) {
            return tokenStack;
        }
    }
        
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
    
    // operators
    reti = regcomp(&regex, "^[*|\\/|+|-]$", REG_EXTENDED);
    if (reti) 
        return FALSE;
    reti = regexec(&regex, cStr, 0, NULL, 0);
    if (!reti) {
        // set type to number
        [token setType:EDTokenTypeFunction];
        return TRUE;
    }
    return FALSE;
}

@end
