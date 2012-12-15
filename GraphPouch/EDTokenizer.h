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
+ (NSMutableArray *)tokenize:(NSString *)str error:(NSError **)error context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)insertImpliedMultiplication:(NSMutableArray *)tokens context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)insertImpliedParenthesis:(NSMutableArray *)tokens context:(NSManagedObjectContext *)context;
+ (BOOL)isValidToken:(EDToken *)token error:(NSError **)error;
+ (BOOL)isValidExpression:(NSMutableArray *)tokens withError:(NSError **)error context:(NSManagedObjectContext *)context;
@end
