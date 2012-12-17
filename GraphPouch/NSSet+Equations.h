//
//  NSSet+Equations.h
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDEquation.h"

@interface NSSet (Equations)

- (EDEquation *)findEquation:(EDEquation *)matchEquation;
- (BOOL)containsEquation:(EDEquation *)matchEquation;

@end
