//
//  EDPanelPropertiesTextViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 2/9/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelViewController.h"
#import "EDTextView.h"
#import "EDTextbox.h"
#import "EDPanelPropertiesTextViewFontSizeText.h"

@interface EDPanelPropertiesTextViewController : EDPanelViewController{
    IBOutlet NSPopUpButton *buttonFonts;
    IBOutlet NSButton *buttonBold;
    IBOutlet NSButton *buttonItalic;
    IBOutlet NSTextField *fieldFontSize;
    EDPanelPropertiesTextViewFontSizeText *_delegateFontSize;
    EDTextView *_currentTextView;
    EDTextbox *_currentTextbox;
}


- (IBAction)onButtonPressedSuperscript:(id)sender;
- (IBAction)onButtonPressedBold:(id)sender;
- (IBAction)onButtonPressedItalic:(id)sender;
- (IBAction)onButtonFontsSelected:(id)sender;
- (void)initButtons:(EDTextView *)textView textbox:(EDTextbox *)textbox;
- (void)updateButtonStates;
@end
