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
- (id)init{
    self = [[EDToken alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameToken inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:nil];
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

+ (EDToken *)multiplierToken{
    EDToken *token = [[EDToken alloc] init];
    [token setTypeRaw:EDTokenTypeFunction];
    [token setIsValid:TRUE];
    [token setPrecedence:[NSNumber numberWithInt:3]];
    [token setAssociationRaw:EDAssociationLeft];
    [token setValue:[[NSMutableString alloc] initWithString:@"*"]];
    return token;
}

+ (EDToken *)leftParenToken{
    EDToken *token = [[EDToken alloc] init];
    [token setTypeRaw:EDTokenTypeFunction];
    [token setIsValid:TRUE];
    [token setPrecedence:[NSNumber numberWithInt:3]];
    [token setAssociationRaw:EDAssociationLeft];
    [token setValue:[[NSMutableString alloc] initWithString:@"("]];
    return token;
}

+ (EDToken *)rightParentToken{
    EDToken *token = [[EDToken alloc] init];
    [token setTypeRaw:EDTokenTypeFunction];
    [token setIsValid:TRUE];
    [token setPrecedence:[NSNumber numberWithInt:3]];
    [token setAssociationRaw:EDAssociationLeft];
    [token setValue:[[NSMutableString alloc] initWithString:@")"]];
    return token;
}

- (void)appendChar:(NSString *)c{
    [self setValue:[[NSString alloc] initWithFormat:@"%@%@", [self value], c]];
}

- (int)length{
    return [[self value] length];
}


- (EDToken *)copy{
    EDToken *token = [[EDToken alloc] init];
    [token setTypeRaw:[self typeRaw]];
    [token setIsValid:[self isValid]];
    [token setPrecedence:[self precedence]];
    [token setAssociationRaw:[self associationRaw]];
    [token setValue:[self value]];
    return token;
}

@end
