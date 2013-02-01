//
//  EDLine.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/30/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDLine.h"
#import "EDPage.h"
#import "EDConstants.h"


@implementation EDLine

@dynamic thickness;
@dynamic page;

- (EDLine *)initWithContext:(NSManagedObjectContext *)context{
    self = [[EDLine alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameLine inManagedObjectContext:context] insertIntoManagedObjectContext:nil];
    if (self){
        // init code
    }
    return self;
}

- (EDLine *)copy:(NSManagedObjectContext *)context{
    EDLine *line = [[EDLine alloc] initWithContext:context];
    [line setSelected:[self selected]];
    [line setElementWidth:[self elementWidth]];
    [line setElementHeight:[self elementHeight]];
    [line setLocationX:[self locationX]];
    [line setLocationY:[self locationY]];
    [line setThickness:[self thickness]];
    
    return line;
}

#pragma mark encoding, decoding this object
- (id)initWithCoder:(NSCoder *)aDecoder{
    // create entity but don't insert it anywhere
    self = [[EDLine alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameLine inManagedObjectContext:[[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext]] insertIntoManagedObjectContext:nil];
    if(self){
        [self setSelected:[aDecoder decodeBoolForKey:EDElementAttributeSelected]];
        [self setLocationX:[aDecoder decodeFloatForKey:EDElementAttributeLocationX]];
        [self setLocationY:[aDecoder decodeFloatForKey:EDElementAttributeLocationY]];
        [self setElementWidth:[aDecoder decodeFloatForKey:EDElementAttributeWidth]];
        [self setElementHeight:[aDecoder decodeFloatForKey:EDElementAttributeHeight]];
        [self setThickness:[aDecoder decodeFloatForKey:EDLineAttributeThickness]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeFloat:[self thickness] forKey:EDLineAttributeThickness];
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
        writableTypes = [[NSArray alloc] initWithObjects:EDUTILine, nil];
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
    return [NSArray arrayWithObject:EDUTILine];
}
@end
