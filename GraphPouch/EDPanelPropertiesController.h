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
#import "EDCoreDataUtility.h"


@interface EDPanelPropertiesController : NSWindowController <NSMenuDelegate>{
    IBOutlet NSMenuItem *menuItemProperties;
    EDPanelPropertiesDocumentController *documentController;
    EDPanelPropertiesGraphController *graphController;
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
    EDCoreDataUtility *_coreData;
}

- (void)togglePropertiesPanel:(id)sender;
- (void)setCorrectView;
- (void)postInitialize;
- (BOOL)panelIsOpen;
- (void)closePanel;
    
@end
