//
//  NSObject+Document.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/12/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSObject (Document)

- (NSManagedObjectContext *)currentContext;
- (NSDocument *)currentDocument;
@end
