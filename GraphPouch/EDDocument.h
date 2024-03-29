//
//  EDDocument.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDAppController.h"
#import "EDMainContentView.h"
#import "EDPagesView.h"
#import "EDPanelPropertiesController.h"
#import "EDWindowControllerAbout.h"
#import "INAppStoreWindow.h"

@class EDWorksheetView;
@class EDWorksheetViewController;
@class EDPagesViewController;

@interface EDDocument : NSPersistentDocument <NSWindowDelegate>{
    IBOutlet NSArrayController *elementsController;
    IBOutlet EDWorksheetViewController *worksheetController;
    IBOutlet EDPagesViewController *pagesController;
    IBOutlet EDWorksheetView *worksheetView;
    IBOutlet EDMainContentView *mainWorksheetView;
    //IBOutlet EDWindow *mainWindow;
    IBOutlet INAppStoreWindow *mainWindow;
    IBOutlet EDPagesView *pagesView;
    EDAppController *appController;
    EDPanelPropertiesController *propertyController;
    EDWindowControllerAbout *aboutController;
    NSManagedObjectContext *_context;
    NSManagedObjectContext *_rootContext;
    NSManagedObjectContext *_copyContext;
    
    // menu
    IBOutlet NSMenuItem *menuPageNext;
}

- (id)getInstance;
- (BOOL)propertiesPanelIsOpen;
- (IBAction)togglePropertiesPanel:(id)sender;
- (IBAction)expressionAdd:(id)sender;
- (IBAction)graphAdd:(id)sender;
- (IBAction)imageAdd:(id)sender;
- (IBAction)lineAdd:(id)sender;
- (IBAction)pageAdd:(id)sender;
- (IBAction)pageNext:(id)sender;
- (IBAction)pagePrevious:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)textboxAdd:(id)sender;
- (IBAction)worksheetItemNext:(id)sender;
- (IBAction)worksheetItemPrevious:(id)sender;
- (IBAction)toggleAboutWindow:(id)sender;
- (void)propertiesPanelDisable:(id)sender;
- (void)propertiesPanelEnable:(id)sender;
@end
