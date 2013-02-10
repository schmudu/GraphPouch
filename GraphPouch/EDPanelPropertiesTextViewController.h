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

@interface EDPanelPropertiesTextViewController : EDPanelViewController{
    IBOutlet NSButton *buttonBold;
    EDTextView *_currentTextView;
}


- (IBAction)onButtonPressedBold:(id)sender;
- (void)initButtons:(EDTextView *)textView;
- (void)updateButtonStates;
@end
