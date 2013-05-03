//
//  EDExpression.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/10/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EDElement.h"

@interface EDExpression : EDElement <NSPasteboardReading, NSPasteboardWriting, NSCoding>

@property float fontSize;
@property (nonatomic, retain) NSString * expression;

- (EDExpression *)initWithContext:(NSManagedObjectContext *)context;
- (EDExpression *)copy:(NSManagedObjectContext *)context;
+ (NSMutableDictionary *)isValidEquationOrExpression:(NSString *)potentialEquation context:(NSManagedObjectContext *)context error:(NSError **)error;
+ (NSMutableDictionary *)validExpression:(NSString *)potentialExpression context:(NSManagedObjectContext *)context error:(NSError **)error;
@end
