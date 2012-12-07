//
//  EDTokenizer.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDToken.h"
#import "EDStack.h"

@interface EDTokenizer : NSObject
+ (NSMutableArray *)tokenize:(NSString *)str error:(NSError **)error;
+ (NSMutableArray *)insertImpliedMultiplication:(NSMutableArray *)tokens;
+ (NSMutableArray *)insertImpliedParenthesis:(NSMutableArray *)tokens;
+ (BOOL)isValidToken:(EDToken *)Token error:(NSError **)error;
+ (BOOL)isValidExpression:(NSMutableArray *)tokens withError:(NSError **)error;
@end
