//
//  EDMenuController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/9/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelPropertiesController.h"

@interface EDMenuController : NSObject{
    NSManagedObjectContext *_context;
}
/*
- (IBAction)togglePropertiesPanel:(id)sender;
- (IBAction)nextPage:(id)sender;
- (IBAction)previousPage:(id)sender;
- (IBAction)addGraph:(id)sender;
- (IBAction)addPage:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)deselectAll:(id)sender;
- (IBAction)nextWorksheetItem:(id)sender;
- (IBAction)previousWorksheetItem:(id)sender;
 */
- (id)initWithContext:(NSManagedObjectContext *)context;
@end
