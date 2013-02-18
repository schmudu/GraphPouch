//
//  EDElement.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EDPage.h"


@interface EDElement : NSManagedObject

@property float locationX, locationY, elementWidth, elementHeight;
@property BOOL selected;

- (void)copyAttributes:(EDElement *)source;
@end
