//
//  EDToken.h
//  GraphPouch
//
//  Created by PATRICK LEE on 12/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EDConstants.h"

@class EDEquation;

@interface EDToken : NSManagedObject

@property BOOL isValid;
@property (nonatomic, retain) NSNumber * precedence;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * association;
@property (nonatomic, retain) EDEquation *equation;

+ (EDToken *)multiplierToken;
+ (EDToken *)leftParenToken;
+ (EDToken *)rightParentToken;
- (void)appendChar:(NSString *)c;
- (int)length;
- (EDToken *)copy;
- (void)setTypeRaw:(EDTokenType)type;
- (EDTokenType)typeRaw;
- (void)setAssociationRaw:(EDAssociation)association;
- (EDAssociation)associationRaw;
@end
