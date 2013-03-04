//
//  EDMenuController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/9/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelPropertiesController.h"

@interface EDMenuController : NSObject{
    NSManagedObjectContext *_context;
}

- (id)initWithContext:(NSManagedObjectContext *)context;
@end
