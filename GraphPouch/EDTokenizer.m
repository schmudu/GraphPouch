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

+ (NSMutableArray *)tokenize:(NSString *)str error:(NSError **)error context:(NSManagedObjectContext *)context{
    int i = 0;
    NSString *currentChar;
    EDToken *currentToken, *potentialToken;
    NSMutableArray *tokenStack = [[NSMutableArray alloc] init];
    currentToken = [[EDToken alloc] initWithContext:context];
    
    // strip white space
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // read in equation
    [EDScanner scanString:str];
    
    while (i<[str length]){
        // get current character
        currentChar = [EDScanner currentChar];
        
        // append chracter
        [currentToken appendChar:currentChar];
        
        if ([EDTokenizer isValidToken:currentToken error:error]) {
            // save token
            potentialToken = [[EDToken alloc] initWithContext:context];
            [potentialToken copy:currentToken];
            
            // increment scanner
            [EDScanner increment];
            i++;
        }
        else {
            if (potentialToken) {
                // push last valid token
                //EDToken *newToken = [potentialToken copy:context];
                EDToken *newToken = [[EDToken alloc] initWithContext:context];
                [newToken copy:potentialToken];
                [tokenStack addObject:newToken];
                
                // release potential token
                potentialToken = nil;
                
                // create new token
                currentToken = [[EDToken alloc] initWithContext:context];
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

+ (BOOL)isValidToken:(EDToken *)token error:(NSError **)error{
    regex_t regex;
    int reti;
    NSString *str = [[NSString alloc] initWithString:[token tokenValue]];
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
        [token setTypeRaw:EDTokenTypeOperator];
        [token setTokenValue:[NSString stringWithFormat:@"%@", str]];
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

+ (BOOL)isValidExpression:(NSMutableArray *)tokens withError:(NSError **)error context:(NSManagedObjectContext *)context{
    EDToken *currentToken, *previousToken;
    int i=0;
    regex_t regex;
    int reti;
    NSString *str;
    const char *cStr;
    
    while (i<[tokens count]){
        // get current token
        currentToken = [tokens objectAtIndex:i];
        
        if (([currentToken typeRaw] == EDTokenTypeFunction) && (([[currentToken tokenValue] isEqualToString:@"c"]) || ([[currentToken tokenValue] isEqualToString:@"co"]))){
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:[NSString stringWithFormat:@"Cannot evaluate expression '%@'. Did you mean 'cos'?",[currentToken tokenValue]] forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
            return FALSE;
        }
        
        if (([currentToken typeRaw] == EDTokenTypeFunction) && (([[currentToken tokenValue] isEqualToString:@"s"]) || ([[currentToken tokenValue] isEqualToString:@"si"]))){
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:[NSString stringWithFormat:@"Cannot evaluate expression '%@'. Did you mean 'sin'?",[currentToken tokenValue]] forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
            return FALSE;
        }
        
        if (([currentToken typeRaw] == EDTokenTypeFunction) && (([[currentToken tokenValue] isEqualToString:@"t"]) || ([[currentToken tokenValue] isEqualToString:@"ta"]))){
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:[NSString stringWithFormat:@"Cannot evaluate expression '%@'. Did you mean 'tan'?",[currentToken tokenValue]] forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
            return FALSE;
        }
        
        if (([currentToken typeRaw] == EDTokenTypeFunction) && ([[currentToken tokenValue] isEqualToString:@"p"])){
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:[NSString stringWithFormat:@"Cannot evaluate expression '%@'. Did you mean 'pi'?",[currentToken tokenValue]] forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
            return FALSE;
        }
        
        if ([currentToken typeRaw] == EDTokenTypeNumber){
            str = [NSString stringWithFormat:@"%@",[currentToken tokenValue]];
            cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
            reti = regcomp(&regex, "^[0-9]+\\.$", REG_EXTENDED);
            if (reti) return FALSE;
            reti = regexec(&regex, cStr, 0, NULL, 0);
            if (!reti){
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                [errorDetail setValue:[NSString stringWithFormat:@"Cannot evaluate term '%@'.",[currentToken tokenValue]] forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
                    return FALSE;        
            }
        }
        
        if (previousToken) {
            if(([previousToken typeRaw] == EDTokenTypeFunction) && ([currentToken typeRaw] == EDTokenTypeFunction)){
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                [errorDetail setValue:[NSString stringWithFormat:@"Cannot evaluate two consecutive function terms: '%@' and '%@'", [previousToken tokenValue], [currentToken tokenValue]] forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
                return FALSE;                 
            }
            
            if(([previousToken typeRaw] == EDTokenTypeOperator) && ([currentToken typeRaw] == EDTokenTypeOperator)){
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                [errorDetail setValue:[NSString stringWithFormat:@"Cannot evaluate two consecutive operators: '%@' and '%@'", [previousToken tokenValue], [currentToken tokenValue]] forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
                return FALSE;                 
            }
        }
        previousToken = currentToken;
        i++;
    }
    return TRUE;
}

+ (NSMutableArray *)insertImpliedMultiplication:(NSMutableArray *)tokens context:(NSManagedObjectContext *)context{
    BOOL addedToken = FALSE;
    EDToken *multiplyToken, *currentToken, *previousToken;
    int i=0;
    while (i<[tokens count]){
        currentToken = [tokens objectAtIndex:i];
        if(previousToken){
            // insert token between identifier and identifier
            if(([previousToken typeRaw] == EDTokenTypeIdentifier) && ([currentToken typeRaw] == EDTokenTypeIdentifier)){
                multiplyToken = [EDToken multiplierToken:context];
                [tokens insertObject:multiplyToken atIndex:i];
                addedToken = TRUE;
            }
            
            // insert token between number and identifier
            if(([previousToken typeRaw] == EDTokenTypeNumber) && ([currentToken typeRaw] == EDTokenTypeIdentifier)){
                multiplyToken = [EDToken multiplierToken:context];
                [tokens insertObject:multiplyToken atIndex:i];
                addedToken = TRUE;
            }
            
            // insert token between number and function
            if(([previousToken typeRaw] == EDTokenTypeNumber) && ([currentToken typeRaw] == EDTokenTypeFunction)){
                multiplyToken = [EDToken multiplierToken:context];
                [tokens insertObject:multiplyToken atIndex:i];
                addedToken = TRUE;
            }
            
            // insert token between right paren and function
            if(([previousToken typeRaw] == EDTokenTypeParenthesis) && ([[previousToken tokenValue] isEqualToString:@")"]) && ([currentToken typeRaw] == EDTokenTypeFunction)){
                multiplyToken = [EDToken multiplierToken:context];
                [tokens insertObject:multiplyToken atIndex:i];
                addedToken = TRUE;
            }
            
            // insert token between right paren and left paren
            if(([previousToken typeRaw] == EDTokenTypeParenthesis) && ([[previousToken tokenValue] isEqualToString:@")"]) && ([currentToken typeRaw] == EDTokenTypeParenthesis) && ([[currentToken tokenValue] isEqualToString:@"("])){
                multiplyToken = [EDToken multiplierToken:context];
                [tokens insertObject:multiplyToken atIndex:i];
                addedToken = TRUE;
            }
        }
        // only set previous token if did not add a token
        if (!addedToken) {
            previousToken = currentToken;
            
        }
        else{
            previousToken = multiplyToken;
            
            // reset
            addedToken = FALSE;
        }
        
        i++;
    }
    return tokens;
}

+ (NSMutableArray *)insertImpliedParenthesis:(NSMutableArray *)tokens context:(NSManagedObjectContext *)context{
    EDToken *currentToken, *previousToken, *nextToken;
    int i=0;
    while (i<[tokens count]){
        currentToken = [tokens objectAtIndex:i];
        
        // get next token
        if (i<[tokens count]-1) {
            nextToken = [tokens objectAtIndex:(i+1)];
        }
        else {
            nextToken = nil;
        }
        
        if(previousToken){
            if(nextToken){
                // if pattern: function number identifier, add paren
                if(([previousToken typeRaw] == EDTokenTypeFunction) && ([currentToken typeRaw] == EDTokenTypeNumber) && ([nextToken typeRaw] == EDTokenTypeIdentifier)){
                    [tokens insertObject:[EDToken leftParenToken:context] atIndex:i];
                    [tokens insertObject:[EDToken rightParentToken:context] atIndex:i+3];
                }
            }
            else {
                // if pattern: function number, add paren
                if(([previousToken typeRaw] == EDTokenTypeFunction) && ([currentToken typeRaw] == EDTokenTypeNumber)){
                    [tokens insertObject:[EDToken leftParenToken:context] atIndex:i];
                    [tokens insertObject:[EDToken rightParentToken:context] atIndex:i+2];
                }
                
                // if pattern: function identifier, add paren
                if(([previousToken typeRaw] == EDTokenTypeFunction) && ([currentToken typeRaw] == EDTokenTypeIdentifier)){
                    [tokens insertObject:[EDToken leftParenToken:context] atIndex:i];
                    [tokens insertObject:[EDToken rightParentToken:context] atIndex:i+2];
                }
                
                // if pattern: function constant, add paren
                if(([previousToken typeRaw] == EDTokenTypeFunction) && ([currentToken typeRaw] == EDTokenTypeConstant)){
                    [tokens insertObject:[EDToken leftParenToken:context] atIndex:i];
                    [tokens insertObject:[EDToken rightParentToken:context] atIndex:i+2];
                }
            }
        }
        previousToken = currentToken;
        i++;
    }
    return tokens;
}
@end
