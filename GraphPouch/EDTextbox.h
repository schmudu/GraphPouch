//
//  EDTextbox.h
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EDElement.h"

@class EDPage;

@interface EDTextbox : EDElement<NSPasteboardReading, NSPasteboardWriting, NSCoding>

@property (nonatomic, retain) id textValue;
@property (nonatomic, retain) EDPage *page;

- (EDTextbox *)initWithContext:(NSManagedObjectContext *)context;
- (EDTextbox *)copy:(NSManagedObjectContext *)context;
@end


