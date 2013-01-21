//
//  EDPanelPropertiesGraphController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelViewController.h"
#import "EDSheetPropertiesGraphEquationController.h"
#import "EDSheetPropertiesGraphErrorController.h"
#import "EDPanelPropertiesGraphTablePoints.h"
#import "EDPanelPropertiesGraphTableEquation.h"

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
    IBOutlet NSTableView *tableEquation;
    IBOutlet NSButton *buttonRemovePoints;
    IBOutlet NSButton *buttonRemoveEquation;
    
#warning need to erase these next four
    IBOutlet NSPopUpButton *buttonMinX;
    IBOutlet NSPopUpButton *buttonMinY;
    IBOutlet NSPopUpButton *buttonMaxX;
    IBOutlet NSPopUpButton *buttonMaxY;
    
    IBOutlet NSTextField *labelMinX;
    IBOutlet NSTextField *labelMinY;
    IBOutlet NSTextField *labelMaxX;
    IBOutlet NSTextField *labelMaxY;
    id _controlTextObj;
    EDSheetPropertiesGraphEquationController *equationController;
    EDSheetPropertiesGraphErrorController *graphErrorController;
    EDPanelPropertiesGraphTablePoints *tablePointsController;
    EDPanelPropertiesGraphTableEquation *tableEquationController;
}

- (IBAction)toggleHasCoordinateAxes:(id)sender;
- (IBAction)toggleHasGrid:(id)sender;
- (IBAction)toggleHasTickMarks:(id)sender;
- (IBAction)toggleHasLabels:(id)sender;
- (IBAction)addNewEquation:(id)sender;
- (IBAction)removeEquation:(id)sender;
- (IBAction)addNewPoint:(id)sender;
- (IBAction)removePoints:(id)sender;
- (IBAction)changeValueMinX:(id)sender;
- (IBAction)changeValueMinY:(id)sender;
- (IBAction)changeValueMaxX:(id)sender;
- (IBAction)changeValueMaxY:(id)sender;
@end
