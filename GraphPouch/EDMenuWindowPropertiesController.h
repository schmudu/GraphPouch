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
#import "EDCoreDataUtility.h"


@interface EDMenuWindowPropertiesController : NSWindowController <NSMenuDelegate>{
    IBOutlet NSMenuItem *menuItemProperties;
    EDMenuWindowPropertiesDocumentController *documentController;
    EDMenuWindowPropertiesGraphController *graphController;
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
    EDCoreDataUtility *_coreData;
}

+ (EDMenuWindowPropertiesController *)getInstance;
- (IBAction)toggleShowProperties:(id)sender;
- (void)setCorrectView;
    
@end
