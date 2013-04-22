//
//  EDImage.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/22/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EDElement.h"

@class EDPage;

@interface EDImage : EDElement<NSPasteboardReading, NSPasteboardWriting, NSCoding>

@property (nonatomic, retain) id imageData;
@property (nonatomic, retain) EDPage *page;

- (EDImage *)initWithContext:(NSManagedObjectContext *)context;
- (EDImage *)copy:(NSManagedObjectContext *)context;
@end