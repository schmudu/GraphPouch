//
//  EDPanelPropertiesController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/28/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelPropertiesBasicController.h"
#import "EDPanelPropertiesDocumentController.h"
#import "EDPanelPropertiesExpressionController.h"
#import "EDPanelPropertiesGraphController.h"
#import "EDPanelPropertiesImageController.h"
#import "EDPanelPropertiesLineController.h"
#import "EDPanelPropertiesBasicWithoutHeightController.h"
#import "EDPanelPropertiesTextViewController.h"
#import "EDTextView.h"
#import "EDTextbox.h"

@interface EDPanelPropertiesController : NSWindowController <NSWindowDelegate>{
    BOOL _panelEnabled;
    IBOutlet NSMenuItem *menuItemProperties;
    EDPanelPropertiesBasicController *basicController;
    EDPanelPropertiesDocumentController *documentController;
    EDPanelPropertiesExpressionController *expressionController;
    EDPanelPropertiesGraphController *graphController;
    EDPanelPropertiesImageController *imageController;
    EDPanelPropertiesBasicWithoutHeightController *basicWithoutHeightController;
    EDPanelPropertiesLineController *lineController;
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
