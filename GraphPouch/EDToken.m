//
//  EDToken.m
//  GraphPouch
//
//  Created by PATRICK LEE on 12/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDToken.h"
#import "EDEquation.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"

@implementation EDToken

@dynamic isValid;
@dynamic precedence;
@dynamic value;
@dynamic type;
@dynamic association;
@dynamic equation;

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    //self = [[EDToken alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameToken inManagedObjectContext:[self managedObjectContext]] insertIntoManagedObjectContext:nil];
    self = [[EDToken alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameToken inManagedObjectContext:[[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setIsValid:[aDecoder decodeBoolForKey:EDTokenAttributeIsValid]];
        [self setPrecedence:[aDecoder decodeObjectForKey:EDTokenAttributePrecedence]];
        [self setValue:[aDecoder decodeObjectForKey:EDTokenAttributeValue]];
        [self setType:[aDecoder decodeObjectForKey:EDTokenAttributeType]];
        [self setAssociation:[aDecoder decodeObjectForKey:EDTokenAttributeAssociation]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:[self isValid] forKey:EDTokenAttributeIsValid];
    [aCoder encodeObject:[self precedence] forKey:EDTokenAttributePrecedence];
    [aCoder encodeObject:[self value] forKey:EDTokenAttributeValue];
    [aCoder encodeObject:[self type] forKey:EDTokenAttributeType];
    [aCoder encodeObject:[self association] forKey:EDTokenAttributeAssociation];
}

- (id)initWithContext:(NSManagedObjectContext *)context{
    self = [[EDToken alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameToken inManagedObjectContext:context] insertIntoManagedObjectContext:nil];
    if (self){
        [self setValue:[NSString stringWithFormat:@""]];
    }
    return self;
}

- (void)setTypeRaw:(EDTokenType)type{
    [self setType:[NSNumber numberWithInt:type]];
}
     
- (EDTokenType)typeRaw{
    return (EDTokenType)[[self type] intValue];
}

- (void)setAssociationRaw:(EDAssociation)association{
    [self setAssociation:[NSNumber numberWithInt:association]];
}

- (EDAssociation)associationRaw{
    return (EDTokenType)[[self association] intValue];
}

+ (EDToken *)multiplierToken:(NSManagedObjectContext *)context{
    EDToken *token = [[EDToken alloc]initWithContext:context];
    [token setTypeRaw:EDTokenTypeOperator];
    [token setIsValid:TRUE];
    [token setPrecedence:[NSNumber numberWithInt:3]];
    [token setAssociationRaw:EDAssociationLeft];
    [token setValue:[[NSMutableString alloc] initWithString:@"*"]];
    return token;
}

+ (EDToken *)leftParenToken:(NSManagedObjectContext *)context{
    EDToken *token = [[EDToken alloc] initWithContext:context];
    [token setTypeRaw:EDTokenTypeParenthesis];
    [token setIsValid:TRUE];
    [token setValue:[[NSMutableString alloc] initWithString:@"("]];
    return token;
}

+ (EDToken *)rightParentToken:(NSManagedObjectContext *)context{
    EDToken *token = [[EDToken alloc] initWithContext:context];
    [token setTypeRaw:EDTokenTypeParenthesis];
    [token setIsValid:TRUE];
    [token setValue:[[NSMutableString alloc] initWithString:@")"]];
    return token;
}

- (void)appendChar:(NSString *)c{
    [self setValue:[[NSString alloc] initWithFormat:@"%@%@", [self value], c]];
}

- (int)length{
    return [[self value] length];
}


- (EDToken *)copy:(NSManagedObjectContext *)context{
    EDToken *token = [[EDToken alloc] initWithContext:context];
    [token setTypeRaw:[self typeRaw]];
    [token setIsValid:[self isValid]];
    [token setPrecedence:[self precedence]];
    [token setAssociationRaw:[self associationRaw]];
    [token setValue:[self value]];
    return token;
}

#pragma mark pasteboard writing protocol
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    NSArray *writableTypes = nil;
    if (!writableTypes){
        writableTypes = [[NSArray alloc] initWithObjects:EDUTIToken, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type{
    //return self;
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    return 0;
}

#pragma mark pasteboard reading protocol
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    // encode object
    return NSPasteboardReadingAsKeyedArchive;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard{
    return [NSArray arrayWithObject:EDUTIToken];
}
@end
