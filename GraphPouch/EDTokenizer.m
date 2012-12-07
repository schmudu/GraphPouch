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

+ (NSMutableArray *)tokenize:(NSString *)str error:(NSError **)error{
    int i = 0;
    NSString *currentChar;
    EDToken *currentToken, *potentialToken;
    NSMutableArray *tokenStack = [[NSMutableArray alloc] init];
    currentToken = [[EDToken alloc] init];
    
    // strip white space
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
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
                [tokenStack addObject:newToken];
                
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
        [tokenStack addObject:potentialToken];
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
    reti = regcomp(&regex, "^([0-9]+|\\.|\\.[0-9]+|[0-9]+\\.|[0-9]+\\.[0-9]+)$", REG_EXTENDED);
    if (reti) 
        return FALSE;
    reti = regexec(&regex, cStr, 0, NULL, 0);
    if (!reti) {
        // set type to number
        [token setTypeRaw:EDTokenTypeNumber];
        return TRUE;
    }
    
    // constants
    reti = regcomp(&regex, "^(p|pi)$", REG_EXTENDED);
    if (reti) 
        return FALSE;
    reti = regexec(&regex, cStr, 0, NULL, 0);
    if (!reti) {
        // set type to number
        [token setTypeRaw:EDTokenTypeConstant];
        return TRUE;
    }
    
    // identifiers
    reti = regcomp(&regex, "^(x)$", REG_EXTENDED);
    if (reti) 
        return FALSE;
    reti = regexec(&regex, cStr, 0, NULL, 0);
    if (!reti) {
        // set type to number
        [token setTypeRaw:EDTokenTypeIdentifier];
        return TRUE;
    }
    
    // parenthesis
    reti = regcomp(&regex, "^(\\(|\\))$", REG_EXTENDED);
    if (reti) 
        return FALSE;
    reti = regexec(&regex, cStr, 0, NULL, 0);
    if (!reti) {
        // set type to number
        [token setTypeRaw:EDTokenTypeParenthesis];
        return TRUE;
    }
    
    // functions
    reti = regcomp(&regex, "^(s|si|sin|c|co|cos)$", REG_EXTENDED);
    if (reti) 
        return FALSE;
    reti = regexec(&regex, cStr, 0, NULL, 0);
    if (!reti) {
        // set type to number
        [token setTypeRaw:EDTokenTypeFunction];
        return TRUE;
    }
    
    // operators
    reti = regcomp(&regex, "^(\\+|\\-|\\*|\\/|\\^)$", REG_EXTENDED);
    if (reti) 
        return FALSE;
    reti = regexec(&regex, cStr, 0, NULL, 0);
    if (!reti) {
        // set type to number
        [token setTypeRaw:EDTokenTypeFunction];
        
        if ([str isEqualToString:@"+"]){
            [token setAssociationRaw:EDAssociationLeft];
            [token setPrecedence:[NSNumber numberWithInt:2]];
        }
        else if ([str isEqualToString:@"-"]){
            [token setAssociationRaw:EDAssociationLeft];
            [token setPrecedence:[NSNumber numberWithInt:2]];
        }
        else if ([str isEqualToString:@"*"]){
            [token setAssociationRaw:EDAssociationLeft];
            [token setPrecedence:[NSNumber numberWithInt:3]];
        }
        else if ([str isEqualToString:@"/"]){
            [token setAssociationRaw:EDAssociationLeft];
            [token setPrecedence:[NSNumber numberWithInt:3]];
        }
        else if ([str isEqualToString:@"^"]){
            [token setAssociationRaw:EDAssociationRight];
            [token setPrecedence:[NSNumber numberWithInt:4]];
        }
        return TRUE;
    }
    
    [token setIsValid:FALSE];
    return FALSE;
}

+ (BOOL)isValidExpression:(NSMutableArray *)tokens withError:(NSError **)error{
    EDToken *currentToken, *previousToken;
    int i=0;
    regex_t regex;
    int reti;
    NSString *str;
    const char *cStr;
    
    while (i<[tokens count]){
        // get current token
        currentToken = [tokens objectAtIndex:i];
        
        if (([currentToken typeRaw] == EDTokenTypeFunction) && ([[currentToken value] isEqualToString:@"c"])){
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Cannot evaluate expression 'c'. Did you mean 'cos'?" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
            return FALSE;
        }
        
        i++;
    }
}
@end
