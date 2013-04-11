//
//  EDExpression.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/10/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDExpression.h"
#import "EDPage.h"
#import "EDConstants.h"

@implementation EDExpression

@dynamic expression;
@dynamic page;

- (EDExpression *)initWithContext:(NSManagedObjectContext *)context{
    self = [[EDExpression alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameExpression inManagedObjectContext:context] insertIntoManagedObjectContext:nil];
    if (self){
        // init code
    }
    return self;
}

- (void)copyAttributes:(EDElement *)source{
    [super copyAttributes:source];
    
    [self setExpression:[(EDExpression *)source expression]];
}

- (EDExpression *)copy:(NSManagedObjectContext *)context{
    EDExpression *line = [[EDExpression alloc] initWithContext:context];
    [line copyAttributes:self];
    
    return line;
}

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    // create entity but don't insert it anywhere
    self = [[EDExpression alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameExpression inManagedObjectContext:[[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setSelected:[aDecoder decodeBoolForKey:EDElementAttributeSelected]];
        [self setLocationX:[aDecoder decodeFloatForKey:EDElementAttributeLocationX]];
        [self setLocationY:[aDecoder decodeFloatForKey:EDElementAttributeLocationY]];
        [self setElementWidth:[aDecoder decodeFloatForKey:EDElementAttributeWidth]];
        [self setElementHeight:[aDecoder decodeFloatForKey:EDElementAttributeHeight]];
        [self setExpression:[aDecoder decodeObjectForKey:EDExpressionAttributeExpression]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[self expression] forKey:EDExpressionAttributeExpression];
    [aCoder encodeBool:[self selected] forKey:EDElementAttributeSelected];
    [aCoder encodeFloat:[self locationX] forKey:EDElementAttributeLocationX];
    [aCoder encodeFloat:[self locationY] forKey:EDElementAttributeLocationY];
    [aCoder encodeFloat:[self elementWidth] forKey:EDElementAttributeWidth];
    [aCoder encodeFloat:[self elementHeight] forKey:EDElementAttributeHeight];
}


#pragma mark pasteboard writing protocol
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    NSArray *writableTypes = nil;
    if (!writableTypes){
        writableTypes = [[NSArray alloc] initWithObjects:EDUTIExpression, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type{
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
    return [NSArray arrayWithObject:EDUTIExpression];
}

@end
