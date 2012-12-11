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
static NSMutableArray *tokens, *output;
static EDStack *operator;

- (NSMutableArray *)parse:(NSMutableArray *)tokens error:(NSError **)error{
    int i=0;
    EDToken *currentToken, *operatorToken, *previousToken;
    output = [NSMutableArray array];
    operator = [[EDStack alloc] init];
}
@end
