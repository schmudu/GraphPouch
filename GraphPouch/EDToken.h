//
//  EDToken.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/14/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EDConstants.h"

@class EDEquation;

@interface EDToken : NSManagedObject

@property (nonatomic, retain) NSNumber * association;
@property BOOL isImplicit;
@property BOOL isValid;
@property (nonatomic, retain) NSNumber * parenthesisCount;
@property (nonatomic, retain) NSNumber * precedence;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * tokenValue;
@property (nonatomic, retain) EDEquation *equation;

- (id)initWithContext:(NSManagedObjectContext *)context;
+ (EDToken *)multiplierToken:(NSManagedObjectContext *)context;
+ (EDToken *)leftParenToken:(NSManagedObjectContext *)context;
+ (EDToken *)rightParentToken:(NSManagedObjectContext *)context;
- (void)incrementParenthesisCount;
- (void)appendChar:(NSString *)c;
- (int)length;
- (void)copy:(EDToken *)sourceToken;
- (void)setTypeRaw:(EDTokenType)type;
- (EDTokenType)typeRaw;
- (void)setAssociationRaw:(EDAssociation)association;
- (EDAssociation)associationRaw;
@end
