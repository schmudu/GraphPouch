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
    IBOutlet NSButton *checkboxHasLabels;
    IBOutlet NSTableView *tablePoints;
    IBOutlet NSButton *buttonRemovePoints;
    IBOutlet NSButton *buttonRemoveEquation;
    IBOutlet NSWindow *sheetEquation;
}

- (IBAction)toggleHasCoordinateAxes:(id)sender;
- (IBAction)toggleHasGrid:(id)sender;
- (IBAction)toggleHasTickMarks:(id)sender;
- (IBAction)toggleHasLabels:(id)sender;
- (IBAction)addNewEquation:(id)sender;
- (IBAction)removeEquation:(id)sender;
- (IBAction)addNewPoint:(id)sender;
- (IBAction)removePoints:(id)sender;
@end
