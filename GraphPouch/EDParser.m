//
//  EDParser.m
//  GraphPouch
//
//  Created by PATRICK LEE on 12/11/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDParser.h"
#import "EDToken.h"
#import "EDStack.h"

@implementation EDParser

+ (NSMutableArray *)parse:(NSMutableArray *)tokens error:(NSError **)error{
    NSMutableArray *output;
    EDStack *operator;
    int i=0;
    EDToken *currentToken, *operatorToken, *previousToken;
    output = [NSMutableArray array];
    operator = [[EDStack alloc] init];
    
    while(i<[tokens count]){
        currentToken = [tokens objectAtIndex:i];
        if([currentToken typeRaw] == EDTokenTypeNumber)
            [output addObject:currentToken];
        else if ([currentToken typeRaw] == EDTokenTypeIdentifier)
            [output addObject:currentToken];
        else if ([currentToken typeRaw] == EDTokenTypeFunction)
            [output addObject:currentToken];
        else if ([currentToken typeRaw] == EDTokenTypeOperator){
            // get precedence of operator
            operatorToken = (EDToken *)[operator getLastObject];
            if (operatorToken){
                if ((([currentToken precedence] <= [operatorToken precedence]) && ([currentToken associationRaw] == EDAssociationLeft)) || ([currentToken precedence] < [operatorToken precedence])) {
                    // pop operator off stack
                    [operator pop];
                    
                    // add to output
                    [output addObject:operatorToken];
                    
                    // push currentToekn to stack
                    [operator push:currentToken];
                }
                else {
                    [operator push:currentToken];
                }
            }
            else {
                [operator push:currentToken];
            }
        }
        else if ([currentToken typeRaw] == EDTokenTypeParenthesis) {
            if([[currentToken tokenValue] isEqualToString:@"("]){
                // push to stack
                [operator push:currentToken];
            }
            else {
                // we matched a right paren, get top token
                BOOL match = false;
                operatorToken = (EDToken *)[operator getLastObject];
                while (([operator count]>0) && (!match)){
                    operatorToken = (EDToken *)[operator pop];
                    
                    // if not open paren then push to output
                    if(![[operatorToken tokenValue] isEqualToString:@"("]){
                        [output addObject:operatorToken];
                    }
                    else 
                        match = true;
                }
                
                // if operator stack is empty and no match then mismatching parenthesis
                if(!match){
                    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                    [errorDetail setValue:[NSString stringWithFormat:@"No matching parenthesis found"] forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
                    return nil;
                }
                
                // if operator is a function then pop it to the output queue
                if ([operator count]>0){
                    EDToken *potentialFunctionToken;
                    potentialFunctionToken = (EDToken *)[operator getLastObject];
                    if((potentialFunctionToken) && ([potentialFunctionToken typeRaw] == EDTokenTypeFunction)){
                        // pop off the last one
                        [operator pop];
                        
                        // push function onto output queue
                        [output addObject:potentialFunctionToken];
                    }
                }
            }
        }
        
        // save
        previousToken = currentToken;
        i++;
    }
 
    // push all objects from operator stack to output
    //NSLog(@"operator:%@ count:%d", operator, [operator count]);
    while (0<[operator count]) {
        currentToken = [operator pop];
        [output addObject:currentToken];
        //NSLog(@"pushing operator token onto output%@", [currentToken tokenValue]);
    }
    
    //NSLog(@"parser returning output:%@", output);
    return output;
}

+ (float)calculate:(NSArray *)stack error:(NSError **)error context:(NSManagedObjectContext *)context varValue:(float)value{
    EDStack *result = [[EDStack alloc] init];
    float answer=0, firstNum=0, secondNum=0, idValue=value;
    EDToken *firstNumToken, *secondNumToken, *resultToken, *idToken;
    
    for (EDToken *token in stack){
        if([token typeRaw] == EDTokenTypeNumber){
            [result push:token];
        }
        else if ([token typeRaw] == EDTokenTypeIdentifier) {
            idToken = [[EDToken alloc] initWithContext:context];
            [idToken setTokenValue:[NSString stringWithFormat:@"%f", idValue]];
            [result push:idToken];
        }
        else if ([token typeRaw] == EDTokenTypeConstant) {
#warning need to figure out the constants
            idToken = [[EDToken alloc] initWithContext:context];
            [idToken setTokenValue:[NSString stringWithFormat:@"%f", idValue]];
            [result push:idToken];
        }
        else if ([token typeRaw] == EDTokenTypeFunction){
            firstNum = [[(EDToken *)[result pop] tokenValue] doubleValue];
            if ([[token tokenValue] isEqualToString:@"sin"])
                answer = sinf(firstNum * M_PI/180);
            else if ([[token tokenValue] isEqualToString:@"cos"])
                answer = cosf(firstNum * M_PI/180);
            
            resultToken = [[EDToken alloc] initWithContext:context];
            [resultToken setTokenValue:[NSString stringWithFormat:@"%f", answer]];
            [result push:resultToken];
        }
        else {
            // token is operator
            if([result count] < 2){
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                [errorDetail setValue:[NSString stringWithFormat:@"Not enough numerical terms to use operator"] forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
                return 0;
            }
            else {
                secondNumToken = (EDToken *)[result pop];
                firstNumToken = (EDToken *)[result pop];
                
                if(([firstNumToken typeRaw] != EDTokenTypeNumber) || ([secondNumToken typeRaw] != EDTokenTypeNumber)){
                    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                    [errorDetail setValue:[NSString stringWithFormat:@"Not enough numerical terms to use operator"] forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
                    return 0;
                }
                else {
                    secondNum = [[secondNumToken tokenValue] doubleValue];
                    firstNum = [[firstNumToken tokenValue] doubleValue];
                    
                    if ([[token tokenValue] isEqualToString:@"+"])
                        answer = firstNum + secondNum;
                    else if ([[token tokenValue] isEqualToString:@"-"])
                        answer = firstNum - secondNum;
                    else if ([[token tokenValue] isEqualToString:@"*"])
                        answer = firstNum * secondNum;
                    else if ([[token tokenValue] isEqualToString:@"/"])
                        answer = firstNum / secondNum;
                    else if ([[token tokenValue] isEqualToString:@"^"])
                        answer = pow(firstNum,secondNum);
                    
                    resultToken = [[EDToken alloc]initWithContext:context];
                    
                    if (isnan(answer) || isinf(answer)){
                        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                        [errorDetail setValue:[NSString stringWithFormat:@"Got infinity/divide_by_zero answer"] forKey:NSLocalizedDescriptionKey];
                        *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
                        return 0;
                    }
                    [resultToken setTokenValue:[NSString stringWithFormat:@"%f", answer]];
                    [result push:resultToken];
                }
            }
        }
    }
    
    return [[(EDToken *)[result getLastObject] tokenValue] floatValue];
}
@end
