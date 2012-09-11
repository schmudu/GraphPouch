//
//  NSObject+CurrentContext.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/11/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSObject+CurrentContext.h"

@implementation NSObject_CurrentContext

- (NSManagedObjectContext *)currentContext{
    return [[[NSDocumentController sharedDocumentController] currentDocument] managedObjectContext];
}

@end
