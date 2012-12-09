//
//  EDDocument.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelPropertiesController.h"
#import "EDMenuController.h"

@class EDWorksheetView;
@class EDWorksheetViewController;
@class EDPagesViewController;

@interface EDDocument : NSPersistentDocument <NSWindowDelegate>{
    IBOutlet NSArrayController *elementsController;
    IBOutlet EDWorksheetViewController *worksheetController;
    IBOutlet EDPagesViewController *pagesController;
    IBOutlet NSView *worksheetView;
    EDPanelPropertiesController *propertyController;
    EDMenuController *menuController;
    NSManagedObjectContext *_context;
}

- (id)getInstance;
- (void)togglePropertiesPanel:(id)sender;
- (BOOL)propertiesPanelIsOpen;
- (IBAction)addPage:(id)sender;
- (IBAction)addGraph:(id)sender;
@end
