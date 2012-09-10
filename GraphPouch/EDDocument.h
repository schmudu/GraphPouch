//
//  EDDocument.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDMenuWindowPropertiesController.h"

@class EDWorksheetView;
@class EDWorksheetViewController;

@interface EDDocument : NSPersistentDocument <NSWindowDelegate>{
    IBOutlet NSArrayController *elementsController;
    IBOutlet EDWorksheetViewController *worksheetController;
    IBOutlet NSView *worksheetView;
    EDMenuWindowPropertiesController *propertyController;
}

- (id)getInstance;
- (void)togglePropertiesPanel:(id)sender;

@end
