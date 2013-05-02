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

@property (nonatomic, retain) NSNumber *zIndex;
@property float locationX, locationY, elementWidth, elementHeight;
@property BOOL selected;
@property (nonatomic, retain) EDPage *page;

- (void)copyAttributes:(EDElement *)source;
- (void)moveZIndexBack:(EDPage *)page;
- (void)moveZIndexBackward:(EDPage *)page;
- (void)moveZIndexForward:(EDPage *)page;
- (void)moveZIndexFront:(EDPage *)page;
- (void)setZIndexAfterInsert:(EDPage *)page;
@end
