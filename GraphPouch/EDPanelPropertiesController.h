//
//  EDPanelPropertiesController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/28/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelPropertiesDocumentController.h"
#import "EDPanelPropertiesExpressionController.h"
#import "EDPanelPropertiesGraphController.h"
#import "EDPanelPropertiesGraphTextboxController.h"
#import "EDPanelPropertiesGraphLineController.h"
#import "EDPanelPropertiesGraphLineTextboxController.h"
#import "EDPanelPropertiesLineController.h"
#import "EDPanelPropertiesLineTextboxController.h"
#import "EDPanelPropertiesTextboxController.h"
#import "EDPanelPropertiesTextViewController.h"
#import "EDTextView.h"
#import "EDTextbox.h"

@interface EDPanelPropertiesController : NSWindowController <NSWindowDelegate>{
    BOOL _panelEnabled;
    IBOutlet NSMenuItem *menuItemProperties;
    EDPanelPropertiesDocumentController *documentController;
    EDPanelPropertiesExpressionController *expressionController;
    EDPanelPropertiesGraphController *graphController;
    EDPanelPropertiesGraphTextboxController *graphTextboxController;
    EDPanelPropertiesGraphLineController *graphLineController;
    EDPanelPropertiesGraphLineTextboxController *graphLineTextboxController;
    EDPanelPropertiesLineController *lineController;
    EDPanelPropertiesLineTextboxController *lineTextboxController;
    EDPanelPropertiesTextboxController *textboxController;
    EDPanelPropertiesTextViewController *textViewController;
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
    EDPanelViewController *_viewController;
    EDTextView *_currentTextView;
    EDTextbox *_currentTextbox;
}

- (void)togglePropertiesPanel:(id)sender;
- (void)setCorrectView;
- (void)postInitialize:(NSManagedObjectContext *)context;
- (BOOL)panelIsOpen;
- (void)closePanel;
- (void)onTextboxDidBeginEditing:(EDTextView *)currentTextView currentTextbox:(EDTextbox *)currentTextbox;
- (void)onTextboxDidEndEditing;
- (void)onTextboxDidChange;
- (void)panelObservingContextDisable;
- (void)panelObservingContextEnable;
@end
