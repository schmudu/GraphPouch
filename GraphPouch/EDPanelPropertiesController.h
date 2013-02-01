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
#import "EDPanelPropertiesLineController.h"


@interface EDPanelPropertiesController : NSWindowController <NSMenuDelegate, NSWindowDelegate>{
    IBOutlet NSMenuItem *menuItemProperties;
    EDPanelPropertiesDocumentController *documentController;
    EDPanelPropertiesGraphController *graphController;
    EDPanelPropertiesLineController *lineController;
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
}

- (void)togglePropertiesPanel:(id)sender;
- (void)setCorrectView;
- (void)postInitialize:(NSManagedObjectContext *)context;
- (BOOL)panelIsOpen;
- (void)closePanel;
    
@end
