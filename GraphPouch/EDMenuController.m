//
//  EDMenuController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/9/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuController.h"
#import "EDPanelPropertiesController.h"
#import "EDConstants.h"

@implementation EDMenuController

- (id)init{
    self = [super init];
    if(!propertiesController){
        propertiesController = [[EDPanelPropertiesController alloc] init];
    }
    return self;
}

- (IBAction)togglePropertiesPanel:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] togglePropertiesPanel:sender];
}

- (IBAction)addGraph:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] addGraph:sender];
}

- (IBAction)addPage:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] addPage:sender];
}
- (IBAction)selectAll:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] selectAll:sender];
}

- (IBAction)deselectAll:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] deselectAll:sender];
}

- (IBAction)nextPage:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] nextPage:sender];
}

- (IBAction)previousPage:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] previousPage:sender];
}
@end
