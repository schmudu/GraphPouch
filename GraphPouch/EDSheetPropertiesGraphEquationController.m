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
- (void)onQuitShortcutPressed:(NSNotification *)note;
- (BOOL)validEquation:(NSString *)potentialEquation;
- (void)showError:(NSError *)error;
- (void)clearError;
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:EDEventQuitDuringEquationSheet];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onQuitShortcutPressed:) name:EDEventQuitDuringEquationSheet object:[self window]];
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
    [self clearError];
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
    //if (!tokens) {
    //NSLog(@"tokens:%@ error received?:%@", tokens, error);
    if (error) {
        [self showError:error];
        return FALSE;
        //NSLog(@"error received:%@", [[error userInfo] valueForKey:NSLocalizedDescriptionKey]);
    }
    else{
        // print out all tokens
        //[tokens printAll:@"value"];
        
        // validate expression
        [EDTokenizer isValidExpression:tokens withError:&error];
        if (error) {
            [self showError:error];
            return FALSE;
        }
    }
    return TRUE;
}

- (void)clearError{
    [errorField setStringValue:@""];
}

- (void)showError:(NSError *)error{
    [errorField setStringValue:[[error userInfo] valueForKey:NSLocalizedDescriptionKey]];
}

#pragma mark keyboard
- (void)onQuitShortcutPressed:(NSNotification *)note{
    [NSApp endSheet:[self window]];
    
    // terminate app
    [NSApp terminate:nil];
}
@end
