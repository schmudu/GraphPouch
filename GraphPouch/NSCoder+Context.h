//
//  NSCoder+Context.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/4/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCoder (Context)
-(void)setContext:(NSManagedObjectContext *)newContext;
-(NSManagedObjectContext *)context;
@end
