//
//  EDExpression.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/10/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDExpression.h"
#import "EDConstants.h"
#import "EDParser.h"
#import "EDPage.h"
#import "EDTokenizer.h"

@implementation EDExpression

@dynamic fontSize;
@dynamic expression;
@dynamic page;

- (EDExpression *)initWithContext:(NSManagedObjectContext *)context{
    self = [[EDExpression alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameExpression inManagedObjectContext:context] insertIntoManagedObjectContext:nil];
    if (self){
        // init code
    }
    return self;
}

- (void)copyAttributes:(EDElement *)source{
    [super copyAttributes:source];
    
    [self setExpression:[(EDExpression *)source expression]];
    [self setFontSize:[(EDExpression *)source fontSize]];
}

- (EDExpression *)copy:(NSManagedObjectContext *)context{
    EDExpression *expression = [[EDExpression alloc] initWithContext:context];
    [expression copyAttributes:self];
    
    return expression;
}

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    // create entity but don't insert it anywhere
    self = [[EDExpression alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameExpression inManagedObjectContext:[[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setSelected:[aDecoder decodeBoolForKey:EDElementAttributeSelected]];
        [self setLocationX:[aDecoder decodeFloatForKey:EDElementAttributeLocationX]];
        [self setLocationY:[aDecoder decodeFloatForKey:EDElementAttributeLocationY]];
        [self setElementWidth:[aDecoder decodeFloatForKey:EDElementAttributeWidth]];
        [self setElementHeight:[aDecoder decodeFloatForKey:EDElementAttributeHeight]];
        [self setExpression:[aDecoder decodeObjectForKey:EDExpressionAttributeExpression]];
        [self setFontSize:[aDecoder decodeFloatForKey:EDExpressionAttributeFontSize]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[self expression] forKey:EDExpressionAttributeExpression];
    [aCoder encodeFloat:[self fontSize] forKey:EDExpressionAttributeFontSize];
    [aCoder encodeBool:[self selected] forKey:EDElementAttributeSelected];
    [aCoder encodeFloat:[self locationX] forKey:EDElementAttributeLocationX];
    [aCoder encodeFloat:[self locationY] forKey:EDElementAttributeLocationY];
    [aCoder encodeFloat:[self elementWidth] forKey:EDElementAttributeWidth];
    [aCoder encodeFloat:[self elementHeight] forKey:EDElementAttributeHeight];
}


#pragma mark pasteboard writing protocol
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    NSArray *writableTypes = nil;
    if (!writableTypes){
        writableTypes = [[NSArray alloc] initWithObjects:EDUTIExpression, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    return 0;
}

#pragma mark pasteboard reading protocol
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    // encode object
    return NSPasteboardReadingAsKeyedArchive;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard{
    return [NSArray arrayWithObject:EDUTIExpression];
}

#pragma mark equation/expression
+ (NSMutableDictionary *)isValidEquationOrExpression:(NSString *)potentialEquation context:(NSManagedObjectContext *)context error:(NSError **)error{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSArray *expressions = [potentialEquation componentsSeparatedByString:@"="];
    
    NSLog(@"expressions:%@", expressions);
    
    if (([expressions count] == 2) || ([expressions count] == 1)){
        // validate both expressions
        NSDictionary *dictExpressionFirst = [EDExpression validExpression:[expressions objectAtIndex:0] context:context error:error];
        
        // error with first expression
        if(*error != nil) return resultDict;
        
        // set dictionary
        [resultDict setObject:[dictExpressionFirst objectForKey:EDKeyParsedTokens] forKey:EDKeyExpressionFirst];
        [resultDict setObject:[NSNumber numberWithInt:EDTypeExpression] forKey:EDKeyExpressionType];
        
        // if there was an equal sign then validate the right hand expression
        if ([expressions count] == 2){
            NSDictionary *dictExpressionSecond = [EDExpression validExpression:[expressions objectAtIndex:1] context:context error:error];
            
            // error with first expression
            if(*error != nil) return resultDict;
            
            // set dictionary
            [resultDict setObject:[dictExpressionSecond objectForKey:EDKeyParsedTokens] forKey:EDKeyExpressionSecond];
            [resultDict setObject:[NSNumber numberWithInt:EDTypeEquation] forKey:EDKeyExpressionType];
        }
    }
    else{
        // too many equal signs
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:[NSString stringWithFormat:@"Too many '=' symbols"] forKey:NSLocalizedDescriptionKey];
        
        if(*error == nil)
            *error = [NSError errorWithDomain:EDErrorDomain code:EDErrorTokenizer userInfo:errorDetail];
    }
    return resultDict;
}


+ (NSMutableDictionary *)validExpression:(NSString *)potentialExpression context:(NSManagedObjectContext *)context error:(NSError **)error{
#warning same code EDSheetPropertiesGraphEquationController
    // this method will accept expressions or equations and return the type
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    //NSError *error;
    NSMutableArray *parsedTokens;
    NSMutableArray *tokens = [EDTokenizer tokenize:potentialExpression error:error context:context];
    
    if (*error != nil) {
        [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
        return results;
    }
    else{
        // print out all tokens
        /*
        NSLog(@"====after tokenize");
        i =0;
        for (EDToken *token in tokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }*/
        
        // validate expression
        [EDTokenizer isValidExpression:tokens withError:error context:context];
        if (*error != nil) {
            [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
            return results;
        }
        
        // insert implied parenthesis
        [EDTokenizer insertImpliedParenthesis:tokens context:context];
        
        // print out all tokens
        /*
        NSLog(@"====after insert parenthesis");
        int i =0;
        for (EDToken *token in tokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }*/
        
        // substitute minus sign for negative one and multiplier token
        [EDTokenizer substituteMinusSign:tokens context:context];
        
        // print out all tokens
        /*
        NSLog(@"====after substitute");
        i =0;
        for (EDToken *token in tokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }*/
        
        // insert implied multiplication
        [EDTokenizer insertImpliedMultiplication:tokens context:context];
        
        // print out all tokens
        /*
        NSLog(@"====after insert implied multiplication");
        i =0;
        for (EDToken *token in tokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }
         */
        
        // parse expression
        parsedTokens = [EDParser parse:tokens error:error];
        if (*error != nil) {
            [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
            return results;
        }
        
        // print out all tokens
        /*
        NSLog(@"====after parsed");
        i =0;
        for (EDToken *token in parsedTokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }*/
        
        // calculate expression
        /*
        float result = [EDParser calculate:parsedTokens error:&error context:context];
        if (error) {
            [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
            return results;
        }*/
        
        // print result
        //NSLog(@"====after parsed: result:%f", result);
    }
    
    // pass in value, other tests exist within calculate
    [EDParser calculate:parsedTokens error:error context:context varValue:5.0];
    
    if (*error != nil) {
        NSLog(@"error by calculating results.");
        [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
        return results;
    }
    
    [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyValidEquation];
    [results setObject:parsedTokens forKey:EDKeyParsedTokens];
    return results;
}


@end
