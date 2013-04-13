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

@class EDPage;

@interface EDExpression : EDElement <NSPasteboardReading, NSPasteboardWriting, NSCoding>

@property (nonatomic, retain) NSString * expression;
@property (nonatomic, retain) EDPage *page;

- (EDExpression *)initWithContext:(NSManagedObjectContext *)context;
- (EDExpression *)copy:(NSManagedObjectContext *)context;
+ (NSMutableDictionary *)isValidEquationOrExpression:(NSString *)potentialEquation context:(NSManagedObjectContext *)context error:(NSError *)error;
+ (NSMutableDictionary *)validEquation:(NSString *)potentialEquation;
@end
