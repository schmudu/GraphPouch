//
//  NSArray+Utilities.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/5/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDPoint.h"

@interface NSMutableArray (Utilities)
- (BOOL)containsPoint:(EDPoint *)point;
- (void)removePoint:(EDPoint *)point;

@end
