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
#import "EDWindow.h"
#import "EDMainContentView.h"
#import "EDPagesView.h"

@class EDWorksheetView;
@class EDWorksheetViewController;
@class EDPagesViewController;

@interface EDDocument : NSPersistentDocument <NSWindowDelegate>{
    IBOutlet NSArrayController *elementsController;
    IBOutlet EDWorksheetViewController *worksheetController;
    IBOutlet EDPagesViewController *pagesController;
    IBOutlet EDWorksheetView *worksheetView;
    IBOutlet EDMainContentView *mainWorksheetView;
    IBOutlet EDWindow *mainWindow;
    IBOutlet EDPagesView *pagesView;
    EDPanelPropertiesController *propertyController;
    EDMenuController *menuController;
    NSManagedObjectContext *_context;
    NSManagedObjectContext *_rootContext;
}

- (id)getInstance;
- (void)togglePropertiesPanel:(id)sender;
- (BOOL)propertiesPanelIsOpen;
- (IBAction)addPage:(id)sender;
- (IBAction)addGraph:(id)sender;
- (void)selectAll:(id)sender;
- (void)deselectAll:(id)sender;
@end
