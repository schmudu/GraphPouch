//
//  EDPanelPropertiesController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/28/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelPropertiesDocumentController.h"
#import "EDPanelPropertiesGraphController.h"
#import "EDPanelPropertiesGraphLineController.h"
#import "EDPanelPropertiesLineController.h"
#import "EDPanelPropertiesTextViewController.h"

@interface EDPanelPropertiesController : NSWindowController <NSMenuDelegate, NSWindowDelegate>{
    IBOutlet NSMenuItem *menuItemProperties;
    EDPanelPropertiesDocumentController *documentController;
    EDPanelPropertiesGraphController *graphController;
    EDPanelPropertiesGraphLineController *graphLineController;
    EDPanelPropertiesLineController *lineController;
    EDPanelPropertiesTextViewController *textViewController;
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
    EDPanelViewController *_viewController;
    BOOL _textViewEdited;
}

- (void)togglePropertiesPanel:(id)sender;
- (void)setCorrectView;
- (void)postInitialize:(NSManagedObjectContext *)context;
- (BOOL)panelIsOpen;
- (void)closePanel;
- (void)onTextboxDidBeginEditing;
- (void)onTextboxDidEndEditing;

@end
