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
#import "EDCoreDataUtility+Equations.h"

@interface EDSheetPropertiesGraphEquationController ()
- (void)updateTokensInEquationInSelectedGraphs:(NSMutableDictionary *)dict equations:(NSArray *)equations;
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
        _newEquation = [[NSString alloc] init];
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventQuitDuringEquationSheet object:[self window]];
}

- (void)initializeSheet:(NSString *)equation index:(int)index{
    if (equation == nil) {
        [fieldEquation setStringValue:[[NSString alloc] initWithFormat:@"Enter equation"]];
    }
    else{
        [fieldEquation setStringValue:equation];
    }
    _equationIndex = index;
    _equationOriginalString = equation;
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
        // set equation string
        [result setObject:equationStr forKey:EDKeyEquation];
        
        // if new equation then add to selected graphs
        if (_equationIndex == EDEquationSheetIndexInvalid) {
            // add equation to dictionary
            [self addTokensToNewEquationInSelectedGraphs:result];
        }
        else {
            //NSArray *commonEquations = [EDCoreDataUtility getCommonEquationsforSelectedGraphs:_context];
            EDEquation *matchEquation = [[EDEquation alloc] initWithContext:_context];
            [matchEquation setEquation:_equationOriginalString];
            
            NSArray *commonEquations = [EDCoreDataUtility getOneCommonEquationFromSelectedGraphsMatchingEquation:matchEquation context:_context];
            
            // update equation
            [self updateTokensInEquationInSelectedGraphs:result equations:commonEquations];
        }
        
        [NSApp endSheet:[self window]];
    }
}

#pragma mark textfield
- (void)controlTextDidChange:(NSNotification *)obj{
    [self setEquationButtonState];
    [self clearError];
}

-(void)controlTextDidEndEditing:(NSNotification *)notification
{
    // See if it was due to a return
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        // if button submit is true then submit equation
        if ([buttonSubmit isEnabled] == TRUE){
            [self onButtonPressedSubmit:nil];
        }
    }
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
#warning same code EDExpression, eventually need to consolidate this.  I changed the method signature and the way errors are tested. However there is a difference in the way '-' and 'x' (identifiers) are consolidated in tokens between this method and EDExpression.m
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    NSError *error;
    NSMutableArray *parsedTokens;
    NSMutableArray *tokens = [EDTokenizer tokenize:potentialEquation error:&error context:_context compactNegativeOne:FALSE];
    
    if (error) {
        [self showError:error];
        [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
        return results;
    }
    else{
        // print out all tokens
        /*
        NSLog(@"====after tokenize");
        int i =0;
        for (EDToken *token in tokens){
            NSLog(@"i:%d token:%@", i, [token tokenValue]);
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
        int i =0;
        for (EDToken *token in tokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }*/
        
        // substitute minus sign for negative one and multiplier token
        [EDTokenizer substituteMinusSign:tokens context:_context];
        
        // print out all tokens
        /*
        NSLog(@"====after substitute");
        i =0;
        for (EDToken *token in tokens){
            NSLog(@"i:%d token:%@", i, token);
            i++;
        }*/
        
        // insert implied multiplication
        [EDTokenizer insertImpliedMultiplication:tokens context:_context];
        
        // print out all tokens
        /*
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
        /*
        float result = [EDParser calculate:parsedTokens error:&error context:_context];
        if (error) {
            [self showError:error];
            [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
            return results;
        }*/
        
        // print result
        //NSLog(@"====after parsed: result:%f", result);
    }
    
    // pass in value, other tests exist within calculate
    [EDParser calculate:parsedTokens error:&error context:_context varValue:5.0];
    
    if (error) {
        NSLog(@"error by calculating results.");
        [self showError:error];
        [results setValue:[NSNumber numberWithBool:FALSE] forKey:EDKeyValidEquation];
        return results;
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
            //newToken = [token copy:_context];
            newToken = [[EDToken alloc] initWithContext:_context];
            [_context insertObject:newToken];
            [newToken copy:token];
            
            // insert into context
            //[_context insertObject:newToken];
            
            [newEquation addTokensObject:newToken];
            i++;
        }
        
        // set string
        [newEquation setEquation:equationStr];
        
        // test print all tokens
        //[newEquation printAllTokens];
        
        // set relationship
        [graph addEquationsObject:newEquation];
    }
}

- (void)updateTokensInEquationInSelectedGraphs:(NSMutableDictionary *)dict equations:(NSArray *)equationsToUpdate{
    NSMutableArray *parsedTokens = [dict objectForKey:EDKeyParsedTokens];
    NSString *equationStr = [dict objectForKey:EDKeyEquation];
    EDToken *newToken;
    
    for (EDEquation *equation in equationsToUpdate){
        // clear all other tokens
        [equation removeAllTokens];
        
        int i=0;
        for (EDToken *token in parsedTokens){
            // create new token and set relationship
            //newToken = [token copy:_context];
            newToken = [[EDToken alloc] initWithContext:_context];
            [_context insertObject:newToken];
            [newToken copy:token];
            
            // insert into context
            //[_context insertObject:newToken];
            
            [equation addTokensObject:newToken];
            i++;
        }
        
        // set string
        [equation setEquation:equationStr];
        
        // test print all tokens
        //[equation printAllTokens];
    }
}

- (IBAction)onButtonPressedHelp:(id)sender{
    NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"com.edcodia.graphpouch.help"];
    [[NSHelpManager sharedHelpManager] openHelpAnchor:@"equation_types"  inBook:locBookName];
}
@end
