//
//  EDSheetPropertiesGraphEquationController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility+Equations.h"
#import "EDEquation.h"
#import "EDGraph.h"
#import "EDParser.h"
#import "EDSheetPropertiesGraphEquationController.h"
#import "EDScanner.h"
#import "EDTokenizer.h"
#import "EDToken.h"
#import "NSManagedObject+EasyFetching.m"

@interface EDSheetPropertiesGraphEquationController ()
- (void)updateTokensInEquationInSelectedGraphs:(NSMutableDictionary *)dict equations:(NSArray *)equations;
- (void)addTokensToNewEquationInSelectedGraphs:(NSMutableDictionary *)dict;
- (void)setEquationButtonState;
- (void)setTypeButtonState:(NSString *)equationType;
- (void)onQuitShortcutPressed:(NSNotification *)note;
- (NSMutableDictionary *)validEquation:(NSString *)potentialEquation;
- (void)showError:(NSError *)error;
- (void)clearError;
- (void)addEquationTypeControls;
- (void)removeEquationTypeControls;
- (void)onInequalityAlphaSliderChanged:(id)sender;
- (void)onInequalityColorWellChanged:(id)sender;
@end

@implementation EDSheetPropertiesGraphEquationController

- (id)initWithContext:(NSManagedObjectContext *)context;
{
    self = [super initWithWindowNibName:@"EDSheetPropertiesGraphEquation"];
    if (self) {
        _context = context;
        _newEquation = [[NSString alloc] init];
        _sheetExpandedForInequality = false;
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventQuitDuringEquationSheet object:[self window]];
}

//- (void)initializeSheet:(NSString *)equation index:(int)index{
- (void)initializeSheet:(EDEquation *)equation index:(int)index{
    if (equation == nil) {
        [fieldEquation setStringValue:[[NSString alloc] initWithFormat:@"Enter equation"]];
    }
    else{
        [fieldEquation setStringValue:[equation equation]];
    }
    
    NSString *equationType = [EDSheetPropertiesGraphEquationController equationTypeFromInt:[[equation equationType] intValue]];
    [self setTypeButtonState:equationType];
    
    
    if (([equationType isEqualToString:EDEquationTypeStringGreaterThan]) ||
        ([equationType isEqualToString:EDEquationTypeStringGreaterThanOrEqual]) ||
        ([equationType isEqualToString:EDEquationTypeStringLessThan]) ||
        ([equationType isEqualToString:EDEquationTypeStringLessThanOrEqual])){
        [self addEquationTypeControls];
    }
    else{
        [self removeEquationTypeControls];
    }
    
    _equationIndex = index;
    _equationOriginalString = [equation equation];
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
        [result setObject:[NSNumber numberWithInteger:[buttonType indexOfItem:[buttonType selectedItem]]] forKey:EDKeyEquationType];
        
        // if inequality set color and alpha as well
        if (([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringGreaterThan]) ||
            ([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringGreaterThanOrEqual]) ||
            ([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringLessThan]) ||
            ([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringLessThanOrEqual])){
            [result setObject:[inequalityColorWell color] forKey:EDKeyEquationInequalityColor];
            [result setObject:[NSNumber numberWithFloat:[inequalityAlphaSlider floatValue]] forKey:EDKeyEquationInequalityAlpha];
        }
        
        
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

#pragma mark type
- (IBAction)onButtonEquationTypeSelected:(id)sender{
    if (([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringGreaterThan]) ||
        ([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringGreaterThanOrEqual]) ||
        ([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringLessThan]) ||
        ([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringLessThanOrEqual])){
        [self addEquationTypeControls];
    }
    else if([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringEqual]){
        [self removeEquationTypeControls];
    }
    [self setEquationButtonState];
}

- (void)removeEquationTypeControls{
    if (!_sheetExpandedForInequality)
        return;
    
    _sheetExpandedForInequality = false;
    
    // due to timing, shrink window after buttons have been removed
    [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(resizeWindowToSmallerDimensions:) userInfo:nil repeats:NO];
    // add remove controls
    if (inequalityAlphaLabel)
        [inequalityAlphaLabel removeFromSuperview];
    
    if (inequalityColorWell)
        [inequalityColorWell removeFromSuperview];
    
    if (inequalityAlphaSlider)
        [inequalityAlphaSlider removeFromSuperview];
    
    if (inequalityRegionAlphaLabel)
        [inequalityRegionAlphaLabel removeFromSuperview];
    
    if (inequalityRegionColorLabel)
        [inequalityRegionColorLabel removeFromSuperview];
    
}

- (void)resizeWindowToSmallerDimensions:(id)sender{
    // make window taller
    [[self window] setFrame:NSMakeRect(0, 0, [[self window] frame].size.width, [[self window] frame].size.height-EDEquationSheetExpansionVertical) display:TRUE animate:TRUE];
    
    // maintain submit and cancel button y pos
    [[buttonSubmit animator] setFrameOrigin:NSMakePoint([buttonSubmit frame].origin.x, EDEquationSheetButtonVerticalPosition)];
    [[buttonCancel animator] setFrameOrigin:NSMakePoint([buttonCancel frame].origin.x, EDEquationSheetButtonVerticalPosition)];
    [[errorField animator] setFrameOrigin:NSMakePoint([errorField frame].origin.x, EDEquationSheetFieldErrorVerticalPosition)];
    
}

- (void)addEquationTypeControls{
    // if already expanded then do nothing
    if (_sheetExpandedForInequality)
        return;
    
    _sheetExpandedForInequality = true;
    // make window taller
    [[self window] setFrame:NSMakeRect(0, 0, [[self window] frame].size.width, [[self window] frame].size.height+EDEquationSheetExpansionVertical) display:TRUE animate:TRUE];
    
    if (!inequalityColorWell){
        inequalityColorWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(90 + 20, [fieldEquation frame].origin.y - [fieldEquation frame].size.height - 13, EDEquationSheetColorWellLength, EDEquationSheetColorWellLength)];
        [inequalityColorWell setTarget:self];
        [inequalityColorWell setAction:@selector(onInequalityColorWellChanged:)];
    }
    
    /*
    if (!inequalityLine){
        inequalityLine = [[NSBox alloc] initWithFrame:NSMakeRect(40, [fieldEquation frame].origin.y - 20, 50, 1)];
        [inequalityLine setBorderType:NSLineBorder];
        [inequalityLine setTitle:@""];
        [inequalityLine setBorderColor:[NSColor blackColor]];
        [inequalityLine setBoxType:NSBoxCustom];
    }*/
    
    if (!inequalityRegionColorLabel){
        inequalityRegionColorLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, [fieldEquation frame].origin.y - 35, 90, 20)];
        [inequalityRegionColorLabel setEditable:FALSE];
        [inequalityRegionColorLabel setSelectable:FALSE];
        [inequalityRegionColorLabel setBordered:FALSE];
        [inequalityRegionColorLabel setDrawsBackground:FALSE];
        [inequalityRegionColorLabel setStringValue:@"Region Color"];
    }
    
    if (!inequalityRegionAlphaLabel){
        inequalityRegionAlphaLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, [fieldEquation frame].origin.y - [fieldEquation frame].size.height - 45, 90, 20)];
        [inequalityRegionAlphaLabel setEditable:FALSE];
        [inequalityRegionAlphaLabel setSelectable:FALSE];
        [inequalityRegionAlphaLabel setBordered:FALSE];
        [inequalityRegionAlphaLabel setDrawsBackground:FALSE];
        [inequalityRegionAlphaLabel setStringValue:@"Region Alpha"];
    }
    
    if (!inequalityAlphaSlider){
        inequalityAlphaSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(90 + 20, [fieldEquation frame].origin.y - [fieldEquation frame].size.height - 45, 70, 20)];
        [inequalityAlphaSlider setMinValue:0.0];
        [inequalityAlphaSlider setMaxValue:1.0];
        [inequalityAlphaSlider setFloatValue:1.0];
        [inequalityAlphaSlider setContinuous:TRUE];
        [inequalityAlphaSlider setTarget:self];
        [inequalityAlphaSlider setAction:@selector(onInequalityAlphaSliderChanged:)];
    }
    
    if (!inequalityAlphaLabel){
        inequalityAlphaLabel = [[NSTextField alloc] initWithFrame:NSMakeRect([inequalityAlphaSlider frame].origin.x + [inequalityAlphaSlider frame].size.width + 10, [fieldEquation frame].origin.y - [fieldEquation frame].size.height - 45, 35, 20)];
        [inequalityAlphaLabel setBordered:FALSE];
        [inequalityAlphaLabel setDrawsBackground:FALSE];
        [inequalityAlphaLabel setBezeled:TRUE];
        [inequalityAlphaLabel setStringValue:@"1.0"];
        [inequalityAlphaLabel setDelegate:self];
    }
    
    // move error message
    //[errorField setFrameOrigin:NSMakePoint([errorField frame].origin.x, [errorField frame].origin.y-EDEquationSheetExpansionVerticalFieldError)];
    [errorField setFrameOrigin:NSMakePoint([errorField frame].origin.x, 30)];
    
    // maintain submit and cancel button y pos
    // maintain submit and cancel button y pos
    [[buttonSubmit animator] setFrameOrigin:NSMakePoint([buttonSubmit frame].origin.x, EDEquationSheetButtonVerticalPosition)];
    [[buttonCancel animator] setFrameOrigin:NSMakePoint([buttonCancel frame].origin.x, EDEquationSheetButtonVerticalPosition)];
    [[errorField animator] setFrameOrigin:NSMakePoint([errorField frame].origin.x, EDEquationSheetFieldErrorVerticalPosition-10)];
    
    // add color well
    [view addSubview:inequalityColorWell];
    [view addSubview:inequalityRegionColorLabel];
    [view addSubview:inequalityRegionAlphaLabel];
    [view addSubview:inequalityAlphaSlider];
    [view addSubview:inequalityAlphaLabel];
}

#pragma mark textfield
- (void)controlTextDidChange:(NSNotification *)obj{
    if ([obj object] == fieldEquation){
        [self setEquationButtonState];
        [self clearError];
    }
    else if([obj object] == inequalityAlphaLabel){
        [self setEquationButtonState];
        [inequalityAlphaSlider setDoubleValue:[[NSNumber numberWithDouble:[[inequalityAlphaLabel stringValue] doubleValue]] doubleValue]];
    }
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

- (void)setTypeButtonState:(NSString *)equationType{
    // set up button
    [buttonType removeAllItems];
    [buttonType addItemsWithTitles:
        [NSArray arrayWithObjects:EDEquationTypeStringEqual,
            EDEquationTypeStringLessThan,
            EDEquationTypeStringLessThanOrEqual,
            EDEquationTypeStringGreaterThan,
            EDEquationTypeStringGreaterThanOrEqual, nil]];
    
    // select appropriate title
    [buttonType selectItemWithTitle:equationType];
}

+ (NSString *)equationTypeFromInt:(int)typeInt{
    switch (typeInt) {
        case EDEquationTypeEqual:
            return EDEquationTypeStringEqual;
        case EDEquationTypeGreaterThan:
            return EDEquationTypeStringGreaterThan;
        case EDEquationTypeGreaterThanOrEqual:
            return EDEquationTypeStringGreaterThanOrEqual;
        case EDEquationTypeLessThan:
            return EDEquationTypeStringLessThan;
        case EDEquationTypeLessThanOrEqual:
            return EDEquationTypeStringLessThanOrEqual;
        default:
            return EDEquationTypeStringEqual;
    }
    return nil;
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
        //newEquation = [[EDEquation alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameEquation inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
        newEquation = [[EDEquation alloc] initWithContext:_context];
        [_context insertObject:newEquation];
        
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
    NSNumber *equationType = [dict objectForKey:EDKeyEquationType];
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
        [equation setEquationType:equationType];
        
        if (([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringGreaterThan]) ||
            ([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringGreaterThanOrEqual]) ||
            ([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringLessThan]) ||
            ([[[buttonType selectedItem] title] isEqualToString:EDEquationTypeStringLessThanOrEqual])){
            [equation setInequalityColor:[dict objectForKey:EDKeyEquationInequalityColor]];
            [equation setInequalityAlpha:[(NSNumber *)[dict objectForKey:EDKeyEquationInequalityAlpha] floatValue]];
        }
        // test print all tokens
        //[equation printAllTokens];
    }
}

- (IBAction)onButtonPressedHelp:(id)sender{
    NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"com.edcodia.graphpouch.help"];
    [[NSHelpManager sharedHelpManager] openHelpAnchor:@"equation_types"  inBook:locBookName];
}

#pragma mark inequality controls
- (void)onInequalityAlphaSliderChanged:(id)sender{
    [inequalityAlphaLabel setStringValue:[NSString stringWithFormat:@"%f", [inequalityAlphaSlider floatValue]]];
    [self setEquationButtonState];
}

- (void)onInequalityColorWellChanged:(id)sender{
    [self setEquationButtonState];
}
@end

