//
//  EDToken.m
//  GraphPouch
//
//  Created by PATRICK LEE on 12/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDToken.h"
#import "EDEquation.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"

@implementation EDToken

@dynamic isValid;
@dynamic precedence;
@dynamic value;
@dynamic type;
@dynamic association;
@dynamic equation;

#warning need to write initWithCoder
- (id)initWithContext:(NSManagedObjectContext *)context{
    self = [[EDToken alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameToken inManagedObjectContext:context] insertIntoManagedObjectContext:nil];
    if (self){
        [self setValue:[NSString stringWithFormat:@""]];
    }
    return self;
}

- (void)setTypeRaw:(EDTokenType)type{
    [self setType:[NSNumber numberWithInt:type]];
}
     
- (EDTokenType)typeRaw{
    return (EDTokenType)[[self type] intValue];
}

- (void)setAssociationRaw:(EDAssociation)association{
    [self setAssociation:[NSNumber numberWithInt:association]];
}

- (EDAssociation)associationRaw{
    return (EDTokenType)[[self association] intValue];
}

+ (EDToken *)multiplierToken:(NSManagedObjectContext *)context{
    EDToken *token = [[EDToken alloc]initWithContext:context];
    [token setTypeRaw:EDTokenTypeOperator];
    [token setIsValid:TRUE];
    [token setPrecedence:[NSNumber numberWithInt:3]];
    [token setAssociationRaw:EDAssociationLeft];
    [token setValue:[[NSMutableString alloc] initWithString:@"*"]];
    return token;
}

+ (EDToken *)leftParenToken:(NSManagedObjectContext *)context{
    EDToken *token = [[EDToken alloc] initWithContext:context];
    [token setTypeRaw:EDTokenTypeParenthesis];
    [token setIsValid:TRUE];
    [token setValue:[[NSMutableString alloc] initWithString:@"("]];
    return token;
}

+ (EDToken *)rightParentToken:(NSManagedObjectContext *)context{
    EDToken *token = [[EDToken alloc] initWithContext:context];
    [token setTypeRaw:EDTokenTypeParenthesis];
    [token setIsValid:TRUE];
    [token setValue:[[NSMutableString alloc] initWithString:@")"]];
    return token;
}

- (void)appendChar:(NSString *)c{
    [self setValue:[[NSString alloc] initWithFormat:@"%@%@", [self value], c]];
}

- (int)length{
    return [[self value] length];
}


- (EDToken *)copy:(NSManagedObjectContext *)context{
    EDToken *token = [[EDToken alloc] initWithContext:context];
    [token setTypeRaw:[self typeRaw]];
    [token setIsValid:[self isValid]];
    [token setPrecedence:[self precedence]];
    [token setAssociationRaw:[self associationRaw]];
    [token setValue:[self value]];
    return token;
}

@end
