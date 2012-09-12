//
//  NSObject+Document.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/12/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSObject+Document.h"

@implementation NSObject (Document)

- (NSManagedObjectContext *)currentContext{
    return [[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext];
}

- (NSDocument *)currentDocument{
    return [[NSDocumentController sharedDocumentController] currentDocument];
}

@end
