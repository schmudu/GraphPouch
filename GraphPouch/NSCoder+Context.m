//
//  NSCoder+Context.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/4/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "NSCoder+Context.h"
#import "/usr/include/objc/runtime.h"

@implementation NSCoder (Context)
NSString const *CONTEXT_IDENTIFIER = @"com.edcodia.identifier.context";

-(void)setContext:(NSManagedObjectContext *)newContext{
    objc_setAssociatedObject(self, &CONTEXT_IDENTIFIER, newContext, OBJC_ASSOCIATION_ASSIGN);
}

-(NSManagedObjectContext *)context{
    return objc_getAssociatedObject(self, &CONTEXT_IDENTIFIER);
}
@end
