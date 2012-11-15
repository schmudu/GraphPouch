//
//  NSArray+Utilities.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/5/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDPoint.h"

@interface NSMutableArray (EDPoint)
- (BOOL)containsPoint:(EDPoint *)point;
- (BOOL)containsPointByCoordinate:(EDPoint *)point;
- (void)removePoint:(EDPoint *)point;
- (void)removePointByCoordinate:(EDPoint *)point;
    
@end
