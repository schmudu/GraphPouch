//
//  EDSheetPropertiesGraphEquationController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDSheetPropertiesGraphEquationController.h"

@interface EDSheetPropertiesGraphEquationController ()
- (void)setEquationButtonState;
@end

@implementation EDSheetPropertiesGraphEquationController

//- (id)initWithWindow:(NSWindow *)window
- (id)init
{
    //self = [super initWithWindow:window];
    self = [super initWithWindowNibName:@"EDSheetPropertiesGraphEquation"];
    if (self) {
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowDidBecomeKey:(NSNotification *)notification{
    [self setEquationButtonState];
}

- (IBAction)onButtonPressedCancel:(id)sender{
    [NSApp endSheet:[self window]];
}

- (IBAction)onButtonPressedSubmit:(id)sender{
    // validate equation
    NSString *equationStr = [fieldEquation stringValue];
    
    // if invalid then show error message
    
    // if valid then close sheet and create/modify equation object
    NSLog(@"submit button pressed.");
}

#pragma mark textfield
- (void)controlTextDidChange:(NSNotification *)obj{
    [self setEquationButtonState];
}

- (void)setEquationButtonState{
    // disable submit button if input is empty
    if ([[fieldEquation stringValue] isEqualToString:@""]) {
        [buttonSubmit setEnabled:FALSE];
    }
    else {
        [buttonSubmit setEnabled:TRUE];
    }
}
@end
