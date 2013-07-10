//
//  NSMutableArray+EDElements.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/10/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDImage.h"
#import "EDExpression.h"
#import "EDGraph.h"
#import "EDLine.h"
#import "EDTextbox.h"

@interface NSMutableArray (EDElements)

#warning worksheet elements
- (EDImage *)getAndRemoveObjectImage;
@end
