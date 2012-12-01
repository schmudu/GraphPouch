//
//  EDTokenizer.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDToken.h"

@interface EDTokenizer : NSObject
+ (NSMutableArray *)tokenize:(NSString *)str;
+ (NSMutableArray *)insertImpliedMultiplication:(NSMutableArray *)tokens;
+ (NSMutableArray *)insertImpliedParenthesis:(NSMutableArray *)tokens;
+ (BOOL)isValidToken:(EDToken *)Token;
+ (BOOL)isValidExpression:(NSMutableArray *)tokens withError:(NSError **)error;
@end
