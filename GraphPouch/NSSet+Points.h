//
//  NSSet+Points.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/9/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDPoint.h"

@interface NSSet (Points)

//- (EDPoint *)findPointByCoordinate:(EDPoint *)matchPoint;
- (EDPoint *)findPoint:(EDPoint *)matchPoint;
//- (BOOL)containsPointByCoordinate:(EDPoint *)matchPoint;
- (BOOL)containsPoint:(EDPoint *)matchPoint;
@end
