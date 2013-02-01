//
//  EDDocument.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelPropertiesController.h"
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
    NSManagedObjectContext *_context;
    NSManagedObjectContext *_rootContext;
    
    // menu
    IBOutlet NSMenuItem *menuPageNext;
}

- (id)getInstance;
- (BOOL)propertiesPanelIsOpen;
- (IBAction)togglePropertiesPanel:(id)sender;
- (IBAction)pageAdd:(id)sender;
- (IBAction)graphAdd:(id)sender;
- (IBAction)lineAdd:(id)sender;
- (IBAction)pageNext:(id)sender;
- (IBAction)pagePrevious:(id)sender;
- (IBAction)textboxAdd:(id)sender;
- (IBAction)worksheetItemNext:(id)sender;
- (IBAction)worksheetItemPrevious:(id)sender;
- (IBAction)paste:(id)sender;
@end
