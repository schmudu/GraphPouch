//
//  NSMutableArray+EDEquation.h
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDEquation.h"

@interface NSMutableArray (EDEquation)

- (BOOL)containsEquation:(EDEquation *)equation;
- (void)removeEquation:(EDEquation *)equation;
@end
