//
//  EDLine.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/30/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EDElement.h"

@class EDPage;

@interface EDLine : EDElement <NSPasteboardReading, NSPasteboardWriting, NSCoding>

@property float thickness;
@property (nonatomic, retain) EDPage *page;

- (EDLine *)initWithContext:(NSManagedObjectContext *)context;
- (EDLine *)copy:(NSManagedObjectContext *)context;

@end
