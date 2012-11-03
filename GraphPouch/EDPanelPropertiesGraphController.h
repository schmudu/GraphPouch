//
//  EDPanelPropertiesGraphController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelViewController.h"

@interface EDPanelPropertiesGraphController : EDPanelViewController <NSTextFieldDelegate>{
    IBOutlet NSTextField *labelWidth;
    IBOutlet NSTextField *labelHeight;
    IBOutlet NSTextField *labelX;
    IBOutlet NSTextField *labelY;
    IBOutlet NSButton *checkboxHasCoordinates;
    IBOutlet NSButton *checkboxGrid;
    IBOutlet NSButton *checkboxHasTickMarks;
}

- (IBAction)toggleHasCoordinateAxes:(id)sender;
- (IBAction)toggleHasGrid:(id)sender;
- (IBAction)toggleHasTickMarks:(id)sender;
@end
