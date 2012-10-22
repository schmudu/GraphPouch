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
    //[[[NSDocumentController sharedDocumentController] currentDocument] addPage:nil];
    //NSLog(@"going to add graph");
}

- (IBAction)addPage:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] addPage:nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutNewPage object:self];
}
@end
