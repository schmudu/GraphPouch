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

@interface EDToken : NSManagedObject <NSCoding, NSPasteboardReading, NSPasteboardReading>

@property BOOL isValid;
@property (nonatomic, retain) NSNumber * precedence;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * association;
@property (nonatomic, retain) EDEquation *equation;

- (id)initWithContext:(NSManagedObjectContext *)context;
+ (EDToken *)multiplierToken:(NSManagedObjectContext *)context;
+ (EDToken *)leftParenToken:(NSManagedObjectContext *)context;
+ (EDToken *)rightParentToken:(NSManagedObjectContext *)context;
- (void)appendChar:(NSString *)c;
- (int)length;
- (EDToken *)copy:(NSManagedObjectContext *)context;
- (void)setTypeRaw:(EDTokenType)type;
- (EDTokenType)typeRaw;
- (void)setAssociationRaw:(EDAssociation)association;
- (EDAssociation)associationRaw;
@end
