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
#import "EDParser.h"
#import "EDEquation.h"
#import "EDToken.h"
#import "EDGraph.h"
#import "NSManagedObject+EasyFetching.m"

@interface EDSheetPropertiesGraphEquationController ()
- (void)addTokensToNewEquationInSelectedGraphs:(NSMutableDictionary *)dict;
- (void)setEquationButtonState;
- (void)onQuitShortcutPressed:(NSNotification *)note;
- (NSMutableDictionary *)validEquation:(NSString *)potentialEquation;
- (void)showError:(NSError *)error;
- (void)clearError;
@end

@implementation EDSheetPropertiesGraphEquationController

- (id)initWithContext:(NSManagedObjectContext *)context;
{
    self = [super initWithWindowNibName:@"EDSheetPropertiesGraphEquation"];
    if (self) {
        _context = context;
        _newEquation = FALSE;
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:EDEventQuitDuringEquationSheet];
}

- (void)initializeSheet:(BOOL)newSheet{
    _newEquation = newSheet;
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
    NSMutableDictionary *result = [self validEquation:equationStr];
    
    // if valid then end sheet
    if ([[result valueForKey:EDKeyValidEquation] boolValue]){
        // if new equation then add to selected graphs
        if (_newEquation) {
            // add equation to dictionary
            [result setObject:equationStr forKey:EDKeyEquation];
            [self addTokensToNewEquationInSelectedGraphs:result];
        }
        else {
            NSLog(@"need to update selected equation.");
        }
        
        [NSApp endSheet:[self window]];
    }
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
- (NSMutableDictionary *)validEquation:(NSString *)potentialEquation{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    NSError *error;
    NSMutableArray *parsedTokens;
    int i = 0;
    NSMutableArray *tokens = [EDTokenizer tokenize:potentialEquation error:&error context:_context];
    
    if (error) {
        [self showError:error];
        [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
        return results;
    }
    else{
        // print out all tokens
        /*
        NSLog(@"====after tokenize");
        i =0;
        for (EDToken *token in tokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }*/
        
        // validate expression
        [EDTokenizer isValidExpression:tokens withError:&error context:_context];
        if (error) {
            [self showError:error];
            [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
            return results;
        }
        
        // insert implied parenthesis
        [EDTokenizer insertImpliedParenthesis:tokens context:_context];
        
        // print out all tokens
        /*
        NSLog(@"====after insert parenthesis");
        i =0;
        for (EDToken *token in tokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }*/
        
        // insert implied multiplication
        [EDTokenizer insertImpliedMultiplication:tokens context:_context];
        
        /*
        // print out all tokens
        NSLog(@"====after insert implied multiplication");
        i =0;
        for (EDToken *token in tokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }*/
        
        // parse expression
        parsedTokens = [EDParser parse:tokens error:&error];
        if (error) {
            [self showError:error];
            [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
            return results;
        }
        
        // print out all tokens
        /*
        NSLog(@"====after parsed");
        i =0;
        for (EDToken *token in parsedTokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }*/
        
        // calculate expression
        float result = [EDParser calculate:parsedTokens error:&error context:_context];
        if (error) {
            [self showError:error];
            [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
            return results;
        }
        
        // print result
        //NSLog(@"====after parsed: result:%f", result);
    }
    [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyValidEquation];
    [results setObject:parsedTokens forKey:EDKeyParsedTokens];
    return results;
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

#pragma mark model
- (void)addTokensToNewEquationInSelectedGraphs:(NSMutableDictionary *)dict{
    NSMutableArray *parsedTokens = [dict objectForKey:EDKeyParsedTokens];
    NSString *equationStr = [dict objectForKey:EDKeyEquation];
    EDToken *newToken;
    EDEquation *newEquation;
    
    
    // get currently selected graphs
    NSArray *selectedGraphs = [EDGraph getAllSelectedObjects:_context];
    
    for (EDGraph *graph in selectedGraphs){
        // create an equation
        newEquation = [[EDEquation alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameEquation inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
        
        int i=0;
        for (EDToken *token in parsedTokens){
            // create new token and set relationship
            newToken = [token copy:_context];
            
            // insert into context
            [_context insertObject:newToken];
            
            [newEquation addTokensObject:newToken];
            i++;
        }
        
        // set string
        [newEquation setEquation:equationStr];
        
        // test print all tokens
        [newEquation printAllTokens];
        
        // set relationship
        [graph addEquationsObject:newEquation];
    }
}
@end
