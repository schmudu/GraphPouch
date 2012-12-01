//
//  EDSheetPropertiesGraphEquationController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDSheetPropertiesGraphEquationController : NSWindowController <NSTextFieldDelegate, NSWindowDelegate>{
    IBOutlet NSButton *buttonCancel;
    IBOutlet NSButton *buttonSubmit;
    IBOutlet NSTextField *fieldEquation;
}

- (IBAction)onButtonPressedCancel:(id)sender;
- (IBAction)onButtonPressedSubmit:(id)sender;
//- (void)initializeSheet;

@end
