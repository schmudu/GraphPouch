//
//  EDMenuWindowPropertiesController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/28/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDMenuWindowPropertiesDocumentController.h"
#import "EDMenuWindowPropertiesGraphController.h"


@interface EDMenuWindowPropertiesController : NSWindowController <NSMenuDelegate>{
    IBOutlet NSMenuItem *menuItemProperties;
    EDMenuWindowPropertiesDocumentController *documentController;
    EDMenuWindowPropertiesGraphController *graphController;
}

- (IBAction)toggleShowProperties:(id)sender;

@end
