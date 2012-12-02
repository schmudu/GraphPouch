//
//  EDSheetPropertiesGraphEquationController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDSheetPropertiesGraphEquationController.h"
#import "EDScanner.h"
#import "EDTokenizer.h"

@interface EDSheetPropertiesGraphEquationController ()
- (void)setEquationButtonState;
- (BOOL)validEquation:(NSString *)potentialEquation;
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
    // do this after sheet is loaded
    [[self window] makeFirstResponder:fieldEquation];
    
    [self setEquationButtonState];
}

- (IBAction)onButtonPressedCancel:(id)sender{
    [NSApp endSheet:[self window]];
}

- (IBAction)onButtonPressedSubmit:(id)sender{
    // validate equation
    NSString *equationStr = [fieldEquation stringValue];
    BOOL validateResult = [self validEquation:equationStr];
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

#pragma mark validate
- (BOOL)validEquation:(NSString *)potentialEquation{
    NSError *error;
    NSMutableArray *tokens = [EDTokenizer tokenize:potentialEquation error:&error];
    if (!tokens) {
        NSLog(@"error received:%@", [[error userInfo] valueForKey:NSLocalizedDescriptionKey]);
    }
    /*
    int i = 0;
    NSString *currentChar;
    
    // read in equation
    [EDScanner scanString:potentialEquation];
    
    while (i<[potentialEquation length]){
        // get current character
        currentChar = [EDScanner currentChar];
        NSLog(@"current char:%@", currentChar);
        
        // increment
        [EDScanner increment];
        i++;
    }
     */
}
@end
