//
//  EDToken.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDToken.h"

@interface EDToken()

@end

@implementation EDToken
@synthesize type;
@synthesize valid;
@synthesize precedence;
@synthesize association;
@synthesize value;

- (id)init{
    self = [super init];
    if (self){
        value = [[NSString alloc] init]; 
    }
    return self;
}
+ (EDToken *)multiplierToken{
    EDToken *token = [[EDToken alloc] init];
    [token setType:EDTokenTypeFunction];
    [token setValid:TRUE];
    [token setPrecedence:3];
    [token setAssociation:EDAssociationLeft];
    [token setValue:[[NSMutableString alloc] initWithString:@"*"]];
    return token;
}

+ (EDToken *)leftParenToken{
    EDToken *token = [[EDToken alloc] init];
    [token setType:EDTokenTypeFunction];
    [token setValid:TRUE];
    [token setPrecedence:3];
    [token setAssociation:EDAssociationLeft];
    [token setValue:[[NSMutableString alloc] initWithString:@"("]];
    return token;
}

+ (EDToken *)rightParentToken{
    EDToken *token = [[EDToken alloc] init];
    [token setType:EDTokenTypeFunction];
    [token setValid:TRUE];
    [token setPrecedence:3];
    [token setAssociation:EDAssociationLeft];
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
    [token setType:[self type]];
    [token setValid:[self valid]];
    [token setPrecedence:[self precedence]];
    [token setAssociation:[self association]];
    [token setValue:[self value]];
    return token;
}
@end
