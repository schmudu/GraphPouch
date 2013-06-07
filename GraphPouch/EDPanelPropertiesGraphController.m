//
//  EDPanelPropertiesGraphController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDCoreDataUtility+Equations.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDCoreDataUtility+Points.h"
#import "EDCoreDataUtility+Worksheet.h"
#import "EDElement.h"
#import "EDExpression.h"
#import "EDGraph.h"
#import "EDPanelPropertiesGraphController.h"
#import "EDPoint.h"
#import "EDSheetPropertiesGraphErrorController.h"
#import "NSColor+Utilities.h"
#import "NSObject+Document.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDPanelPropertiesGraphController ()
//- (void)changeSelectedElementsAttribute:(NSString *)key newValue:(id)newValue;
- (void)addNewExpressions:(NSArray *)expressions;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)didEndSheetGraphErrorMinX:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)didEndSheetGraphErrorMaxX:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)didEndSheetGraphErrorScaleX:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)didEndSheetGraphErrorScaleY:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)didEndSheetGraphErrorLabelIntervalX:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)didEndSheetGraphErrorLabelIntervalY:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)onContextChanged:(NSNotification *)note;
- (void)onDoubleClickEquation:(id)sender;
@end

@implementation EDPanelPropertiesGraphController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currentSheet = nil;
    }
    
    return self;
}

- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context{
    _context = context;
    
    if (!equationController) {
        equationController = [[EDSheetPropertiesGraphEquationController alloc] initWithContext:_context];
    }
    if (!graphErrorController) {
        graphErrorController = [[EDSheetPropertiesGraphErrorController alloc] initWithContext:_context];
    }
    // this method will only be called if only graphs are shown
    // get all of the graphs selected
    [self setElementLabel:labelHeight attribute:EDElementAttributeHeight];
    [self setElementLabel:labelWidth attribute:EDElementAttributeWidth];
    [self setElementLabel:labelX attribute:EDElementAttributeLocationX];
    [self setElementLabel:labelY attribute:EDElementAttributeLocationY];
    [self setElementLabel:labelMinX attribute:EDGraphAttributeMinValueX];
    [self setElementLabel:labelMaxX attribute:EDGraphAttributeMaxValueX];
    [self setElementLabel:labelMinY attribute:EDGraphAttributeMinValueY];
    [self setElementLabel:labelMaxY attribute:EDGraphAttributeMaxValueY];
    [self setElementLabel:labelScaleX attribute:EDGraphAttributeScaleX];
    [self setElementLabel:labelScaleY attribute:EDGraphAttributeScaleY];
    [self setElementLabel:labelIntervalX attribute:EDGraphAttributeLabelIntervalX];
    [self setElementLabel:labelIntervalY attribute:EDGraphAttributeLabelIntervalY];
    [self setElementCheckbox:checkboxHasCoordinates attribute:EDGraphAttributeCoordinateAxes];
    [self setElementCheckbox:checkboxHasLabels attribute:EDGraphAttributeLabels];
    [self setElementCheckbox:checkboxGrid attribute:EDGraphAttributeGridLines];
    [self setElementCheckbox:checkboxHasTickMarks attribute:EDGraphAttributeTickMarks];
    
    
    // initialize table points datasource and delegate
    if (!tablePointsController){
        tablePointsController = [[EDPanelPropertiesGraphTablePoints alloc] initWithContext:_context table:tablePoints removeButton:buttonRemovePoints];
        [tablePoints setDelegate:tablePointsController];
        [tablePoints setDataSource:tablePointsController];
    }
    
    // initialize table equation datasource and delegate
    if (!tableEquationController){
        tableEquationController = [[EDPanelPropertiesGraphTableEquation alloc] initWithContext:_context table:tableEquation removeButton:buttonRemoveEquation exportButton:buttonExportEquation];
        [tableEquation setDelegate:tableEquationController];
        [tableEquation setDataSource:tableEquationController];
    }
    
    // set button state
    if ([tablePoints numberOfSelectedRows] == 0) {
        [buttonRemovePoints setEnabled:FALSE];
    }
    
    // set button state
    if ([tableEquation numberOfSelectedRows] == 0) {
        [buttonRemoveEquation setEnabled:FALSE];
        [buttonExportEquation setEnabled:FALSE];
    }
    
    //listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    /*
     [tableEquation setTarget:self];
    [tableEquation setDoubleAction:@selector(onDoubleClickEquation:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelHeight];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelWidth];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelMinX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelMaxX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelMinY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelMaxY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelScaleX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelScaleY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelIntervalX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelIntervalY];
     */
}

- (void)viewDidLoad{
    //listen
    [tableEquation setTarget:self];
    [tableEquation setDoubleAction:@selector(onDoubleClickEquation:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelHeight];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelWidth];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelMinX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelMaxX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelMinY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelMaxY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelScaleX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelScaleY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelIntervalX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelIntervalY];
     
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelHeight];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelWidth];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelX];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelY];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelMinX];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelMaxX];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelMinY];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelMaxY];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelScaleX];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelScaleY];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelIntervalX];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelIntervalY];
}

#pragma mark context
- (void)onContextChanged:(NSNotification *)note{
    // must end sheet if it's up
    if (_currentSheet){
        //end sheet if it's showing
        [NSApp endSheet:_currentSheet];
    }
}

#pragma mark keyboard
- (void)keyDown:(NSEvent *)theEvent{
    NSLog(@"panel controller: key down.");
}

- (void)setElementHasCoordinateAxes{
    // find if there are differences in values of selected objects
    NSMutableDictionary *results = [self checkForSameBoolValueInLabelsForKey:EDGraphAttributeCoordinateAxes];
    
    // set state
    if ([[results valueForKey:EDKeyDiff] boolValue]) {
        [checkboxHasCoordinates setState:NSMixedState];
    }
    else {
        if ([[results valueForKey:EDKeyValue] boolValue]) 
            [checkboxHasCoordinates setState:NSOnState];
        else
            [checkboxHasCoordinates setState:NSOffState];
    }
}

#pragma mark text field delegation
- (void)controlTextDidEndEditing:(NSNotification *)obj{
    // if field did not change then do nothing
    if (!_fieldChanged)
        return;
    
    // only change the specific attribute that was changed
    if ([obj object] == labelX) {
        [self changeSelectedElementsAttribute:EDElementAttributeLocationX newValue:[[NSNumber alloc] initWithFloat:[[labelX stringValue] floatValue]]];
    }
    else if ([obj object] == labelY) {
        [self changeSelectedElementsAttribute:EDElementAttributeLocationY newValue:[[NSNumber alloc] initWithFloat:[[labelY stringValue] floatValue]]];
    }
    else if ([obj object] == labelWidth) {
        [self changeSelectedElementsAttribute:EDElementAttributeWidth newValue:[[NSNumber alloc] initWithFloat:[[labelWidth stringValue] floatValue]]];
    }
    else if ([obj object] == labelHeight) {
        [self changeSelectedElementsAttribute:EDElementAttributeHeight newValue:[[NSNumber alloc] initWithFloat:[[labelHeight stringValue] floatValue]]];
    }
    else if ([obj object] == labelMinX) {
        // verify that value does not exceed max nor lower than min
        // both values cannot be zero
        if ((([[labelMinX stringValue] intValue] == 0) && ([[labelMaxX stringValue] intValue] == 0)) || ([[labelMinX stringValue] intValue] > EDGraphValueMinThresholdMax) || ([[labelMinX stringValue] intValue] < EDGraphValueMinThresholdMin)){
            // if this object has already sent message then do not show sheet
            if (_controlTextObj == labelMaxX) {
#warning change tab order on interface then change this special condition
                // special: since min/max cannot both be 0
                // restore previous value
                [self setElementLabel:labelMaxX attribute:EDGraphAttributeMaxValueX];
                
                // do nothing
                _controlTextObj = [obj object];
            }
            if (_controlTextObj == labelMinX) {
                // do nothing
                _controlTextObj = nil;
            }
            else{
                // save
                _controlTextObj = [obj object];
            
                // error message
                if (([[labelMinX stringValue] intValue] == 0) && ([[labelMaxX stringValue] intValue] == 0))
                    [graphErrorController initializeSheet:[NSString stringWithFormat:@"Minimum X and Maximum X cannot both be 0."]];
                else
                    [graphErrorController initializeSheet:[NSString stringWithFormat:@"Minimum X value must be less than %d and greater than %d", EDGraphValueMinThresholdMax, EDGraphValueMinThresholdMin]];
                
                // launch error sheet
                [NSApp beginSheet:[graphErrorController window] modalForWindow:[[self view] window] modalDelegate:self didEndSelector:@selector(didEndSheetGraphErrorMinX:returnCode:contextInfo:) contextInfo:nil];
                _currentSheet = [graphErrorController window];
            }
            
            // reset value
            [self setElementLabel:labelMinX attribute:EDGraphAttributeMinValueX];
        }
        else{
            [self changeSelectedElementsAttribute:EDGraphAttributeMinValueX newValue:[[NSNumber alloc] initWithInt:[[labelMinX stringValue] intValue]]];
        }
    }
    else if ([obj object] == labelMaxX) {
        // verify that value does not exceed max nor lower than min
        // both values cannot be zero
        if ((([[labelMinX stringValue] intValue] == 0) && ([[labelMaxX stringValue] intValue] == 0)) || ([[labelMaxX stringValue] intValue] > EDGraphValueMaxThresholdMax) || ([[labelMaxX stringValue] intValue] < EDGraphValueMaxThresholdMin)){
            // if this object has already sent message then do nothing
            if (_controlTextObj == labelMinX) {
#warning change tab order on interface then change this special condition
                // special: since min/max cannot both be 0
                // restore previous value
                [self setElementLabel:labelMinX attribute:EDGraphAttributeMinValueX];
                
                // do nothing
                _controlTextObj = [obj object];
            }
            else if (_controlTextObj == labelMaxX) {
                // do nothing
                _controlTextObj = nil;
            }
            else{
                // save
                _controlTextObj = [obj object];
            
                // error message
                if (([[labelMinX stringValue] intValue] == 0) && ([[labelMaxX stringValue] intValue] == 0))
                    [graphErrorController initializeSheet:[NSString stringWithFormat:@"Minimum X and Maximum X cannot both be 0."]];
                else
                    [graphErrorController initializeSheet:[NSString stringWithFormat:@"Maximum X value must be less than %d and greater than %d", EDGraphValueMaxThresholdMax, EDGraphValueMaxThresholdMin]];
                
                // launch error sheet
                [NSApp beginSheet:[graphErrorController window] modalForWindow:[[self view] window] modalDelegate:self didEndSelector:@selector(didEndSheetGraphErrorMaxX:returnCode:contextInfo:) contextInfo:nil];
                _currentSheet = [graphErrorController window];
            }
            
            // reset value
            [self setElementLabel:labelMaxX attribute:EDGraphAttributeMaxValueX];
        }
        else{
            [self changeSelectedElementsAttribute:EDGraphAttributeMaxValueX newValue:[[NSNumber alloc] initWithInt:[[labelMaxX stringValue] intValue]]];
        }
    }
    else if ([obj object] == labelMinY) {
        // verify that max is not 0 and then min x is greater than -100
        if ((([[labelMinY stringValue] intValue] == 0) && ([[labelMaxY stringValue] intValue] == 0)) || ([[labelMinY stringValue] intValue] > EDGraphValueMinThresholdMax) || ([[labelMinY stringValue] intValue] < EDGraphValueMinThresholdMin)){
            // if this object has already sent message then do not show sheet, otherwise infinite loop
            if (_controlTextObj == labelMaxY) {
#warning change tab order on interface then change this special condition
                // special: since min/max cannot both be 0
                // restore previous value
                [self setElementLabel:labelMaxY attribute:EDGraphAttributeMaxValueY];
                
                // do nothing
                _controlTextObj = [obj object];
            }
            else if (_controlTextObj == labelMinY) {
                // do not show sheet
                _controlTextObj = nil;
            }
            else{
                // save
                _controlTextObj = [obj object];
            
                if (([[labelMinY stringValue] intValue] == 0) && ([[labelMaxY stringValue] intValue] == 0))
                    [graphErrorController initializeSheet:[NSString stringWithFormat:@"Minimum Y and Maximum Y cannot both be 0."]];
                else
                    [graphErrorController initializeSheet:[NSString stringWithFormat:@"Minimum Y value must be less than %d and greater than %d", EDGraphValueMinThresholdMax, EDGraphValueMinThresholdMin]];
                
                // launch error sheet
                [NSApp beginSheet:[graphErrorController window] modalForWindow:[[self view] window] modalDelegate:self didEndSelector:@selector(didEndSheetGraphErrorMinY:returnCode:contextInfo:) contextInfo:nil];
                _currentSheet = [graphErrorController window];
            }
            
            // reset value
            [self setElementLabel:labelMinY attribute:EDGraphAttributeMinValueY];
        }
        else{
            [self changeSelectedElementsAttribute:EDGraphAttributeMinValueY newValue:[[NSNumber alloc] initWithInt:[[labelMinY stringValue] intValue]]];
        }
    }
    else if ([obj object] == labelMaxY) {
        // verify that max is not 0 and then min x is greater than -100
        if ((([[labelMinY stringValue] intValue] == 0) && ([[labelMaxY stringValue] intValue] == 0)) || ([[labelMaxY stringValue] intValue] > EDGraphValueMaxThresholdMax) || ([[labelMaxY stringValue] intValue] < EDGraphValueMaxThresholdMin)){
            // if this object has already sent message then do nothing
            if (_controlTextObj == labelMinY) {
#warning change tab order on interface then change this special condition
                // special: since min/max cannot both be 0
                // restore previous value
                [self setElementLabel:labelMinY attribute:EDGraphAttributeMinValueY];
                
                // do nothing
                _controlTextObj = [obj object];
            }
            else if (_controlTextObj == labelMaxY) {
                // do nothing
                _controlTextObj = nil;
            }
            else{
                // save
                _controlTextObj = [obj object];
            
                // launch error sheet
                if (([[labelMinY stringValue] intValue] == 0) && ([[labelMaxY stringValue] intValue] == 0))
                    [graphErrorController initializeSheet:[NSString stringWithFormat:@"Minimum Y and Maximum Y cannot both be 0."]];
                else
                    [graphErrorController initializeSheet:[NSString stringWithFormat:@"Maximum Y value must be less than %d and greater than %d", EDGraphValueMaxThresholdMax, EDGraphValueMaxThresholdMin]];
                
                // launch sheet
                [NSApp beginSheet:[graphErrorController window] modalForWindow:[[self view] window] modalDelegate:self didEndSelector:@selector(didEndSheetGraphErrorMaxY:returnCode:contextInfo:) contextInfo:nil];
                _currentSheet = [graphErrorController window];
            }
            
            // reset value
            [self setElementLabel:labelMinY attribute:EDGraphAttributeMinValueY];
        }
        else{
            [self changeSelectedElementsAttribute:EDGraphAttributeMaxValueY newValue:[[NSNumber alloc] initWithInt:[[labelMaxY stringValue] intValue]]];
        }
    }
    else if ([obj object] == labelScaleX) {
        // verify that value does not exceed max nor lower than min
        if (([[labelScaleX stringValue] intValue] > EDGraphScaleMax) || ([[labelScaleX stringValue] intValue] < EDGraphScaleMin)){
            // if this object has already sent message then do nothing
            if (_controlTextObj == labelScaleX) {
                // do nothing
                _controlTextObj = nil;
            }
            else{
                // save
                _controlTextObj = [obj object];
            
                // error message
                [graphErrorController initializeSheet:[NSString stringWithFormat:@"Scale X value must be less than %d and greater than %d", EDGraphScaleMax, EDGraphScaleMin]];
                
                // launch error sheet
                [NSApp beginSheet:[graphErrorController window] modalForWindow:[[self view] window] modalDelegate:self didEndSelector:@selector(didEndSheetGraphErrorScaleX:returnCode:contextInfo:) contextInfo:nil];
                _currentSheet = [graphErrorController window];
            }
        }
        else{
            [self changeSelectedElementsAttribute:EDGraphAttributeScaleX newValue:[[NSNumber alloc] initWithInt:[[labelScaleX stringValue] intValue]]];
        }
    }
    else if ([obj object] == labelScaleY) {
        // verify that value does not exceed max nor lower than min
        if (([[labelScaleY stringValue] intValue] > EDGraphScaleMax) || ([[labelScaleY stringValue] intValue] < EDGraphScaleMin)){
            // if this object has already sent message then do nothing
            if (_controlTextObj == labelScaleY) {
                // do nothing
                _controlTextObj = nil;
            }
            else{
                // save
                _controlTextObj = [obj object];
            
                // error message
                [graphErrorController initializeSheet:[NSString stringWithFormat:@"Scale Y value must be less than %d and greater than %d", EDGraphScaleMax, EDGraphScaleMin]];
                
                // launch error sheet
                [NSApp beginSheet:[graphErrorController window] modalForWindow:[[self view] window] modalDelegate:self didEndSelector:@selector(didEndSheetGraphErrorScaleY:returnCode:contextInfo:) contextInfo:nil];
                _currentSheet = [graphErrorController window];
            }
        }
        else{
            [self changeSelectedElementsAttribute:EDGraphAttributeScaleY newValue:[[NSNumber alloc] initWithInt:[[labelScaleY stringValue] intValue]]];
        }
    }
    else if ([obj object] == labelIntervalX) {
        // verify that value does not exceed max nor lower than min
        if (([[labelIntervalX stringValue] intValue] > EDGraphLabelIntervalMax) || ([[labelIntervalX stringValue] intValue] < EDGraphLabelIntervalMin)){
            // if this object has already sent message then do nothing
            if (_controlTextObj == labelIntervalX) {
                // do nothing
                _controlTextObj = nil;
            }
            else{
                // save
                _controlTextObj = [obj object];
            
                // error message
                [graphErrorController initializeSheet:[NSString stringWithFormat:@"X Label Interval value must be less than %d and greater than %d", EDGraphLabelIntervalMax, EDGraphLabelIntervalMin]];
                
                // launch error sheet
                [NSApp beginSheet:[graphErrorController window] modalForWindow:[[self view] window] modalDelegate:self didEndSelector:@selector(didEndSheetGraphErrorLabelIntervalX:returnCode:contextInfo:) contextInfo:nil];
                _currentSheet = [graphErrorController window];
            }
        }
        else{
            [self changeSelectedElementsAttribute:EDGraphAttributeLabelIntervalX newValue:[[NSNumber alloc] initWithInt:[[labelIntervalX stringValue] intValue]]];
        }
    }
    else if ([obj object] == labelIntervalY) {
        // verify that value does not exceed max nor lower than min
        if (([[labelIntervalY stringValue] intValue] > EDGraphLabelIntervalMax) || ([[labelIntervalY stringValue] intValue] < EDGraphLabelIntervalMin)){
            // if this object has already sent message then do nothing
            if (_controlTextObj == labelIntervalY) {
                // do nothing
                _controlTextObj = nil;
            }
            else{
                // save
                _controlTextObj = [obj object];
            
                // error message
                [graphErrorController initializeSheet:[NSString stringWithFormat:@"Y Label Interval value must be less than %d and greater than %d", EDGraphLabelIntervalMax, EDGraphLabelIntervalMin]];
                
                // launch error sheet
                [NSApp beginSheet:[graphErrorController window] modalForWindow:[[self view] window] modalDelegate:self didEndSelector:@selector(didEndSheetGraphErrorLabelIntervalY:returnCode:contextInfo:) contextInfo:nil];
                _currentSheet = [graphErrorController window];
            }
        }
        else{
            [self changeSelectedElementsAttribute:EDGraphAttributeLabelIntervalY newValue:[[NSNumber alloc] initWithInt:[[labelIntervalY stringValue] intValue]]];
        }
    }
}

#pragma mark checkbox
- (IBAction)toggleHasGrid:(id)sender{
    // if toggle then set state to on
    if([checkboxGrid state] == NSMixedState)
        [checkboxGrid setState:NSOnState];
    
    [self changeSelectedElementsAttribute:EDGraphAttributeGridLines newValue:[[NSNumber alloc] initWithBool:[checkboxGrid state]]];
}

- (IBAction)toggleHasCoordinateAxes:(id)sender{
    // if toggle then set state to on
    // if toggled to off then turn tick marks off as well, and disable it
    if([checkboxHasCoordinates state] == NSOffState){
        [checkboxHasTickMarks setState:NSOffState];
        [checkboxHasTickMarks setEnabled:FALSE];
        [self changeSelectedElementsAttribute:EDGraphAttributeTickMarks newValue:[[NSNumber alloc] initWithBool:[checkboxHasTickMarks state]]];
        
        [checkboxHasLabels setEnabled:FALSE];
        [checkboxHasLabels setState:NSOffState];
        [self changeSelectedElementsAttribute:EDGraphAttributeLabels newValue:[[NSNumber alloc] initWithBool:[checkboxHasLabels state]]];
    }
    else if([checkboxHasCoordinates state] == NSOnState){
        [checkboxHasTickMarks setEnabled:TRUE];
        [checkboxHasLabels setEnabled:TRUE];
    }
    else if([checkboxHasCoordinates state] == NSMixedState){
        [checkboxHasCoordinates setState:NSOnState];
        
        // turn on tick marks too
        [checkboxHasTickMarks setEnabled:TRUE];
        [checkboxHasTickMarks setState:NSOnState];
        [self changeSelectedElementsAttribute:EDGraphAttributeTickMarks newValue:[[NSNumber alloc] initWithBool:[checkboxHasTickMarks state]]];
        
        // turn on labels too
        [checkboxHasLabels setEnabled:TRUE];
        [checkboxHasLabels setState:NSOnState];
        [self changeSelectedElementsAttribute:EDGraphAttributeLabels newValue:[[NSNumber alloc] initWithBool:[checkboxHasLabels state]]];
    }
    
    [self changeSelectedElementsAttribute:EDGraphAttributeCoordinateAxes newValue:[[NSNumber alloc] initWithBool:[checkboxHasCoordinates state]]];
}

- (IBAction)toggleHasTickMarks:(id)sender{
    // if toggle then set state to on
    if([checkboxHasTickMarks state] == NSMixedState)
        [checkboxHasTickMarks setState:NSOnState];
    
    
    [self changeSelectedElementsAttribute:EDGraphAttributeTickMarks newValue:[[NSNumber alloc] initWithBool:[checkboxHasTickMarks state]]];
}

- (IBAction)toggleHasLabels:(id)sender{
    // if toggle then set state to on
    if([checkboxHasLabels state] == NSMixedState)
        [checkboxHasLabels setState:NSOnState];
    
    
    [self changeSelectedElementsAttribute:EDGraphAttributeLabels newValue:[[NSNumber alloc] initWithBool:[checkboxHasLabels state]]];   
}

#pragma mark graph points
- (IBAction)addNewPoint:(id)sender{
    // get currently selected graphs
    NSArray *selectedGraphs = [EDGraph getAllSelectedObjects:_context];
    
    // create new point for each graph
    for (EDGraph *graph in selectedGraphs){
        EDPoint *newPoint = [[EDPoint alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePoint inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
        // set relationship
        [graph addPointsObject:newPoint];
    }
}

- (IBAction)removePoints:(id)sender{
    // get all selected points and their attributes
    NSMutableArray *selectedIndices = [[NSMutableArray alloc] init];
    NSIndexSet *selectedIndexSet = [tablePoints selectedRowIndexes];
    
    [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [selectedIndices addObject:[[NSNumber alloc] initWithInt:(int)idx]];
    }];
    
    // get all the common points
    NSArray *commonPoints = [EDCoreDataUtility getCommonPointsforSelectedGraphs:_context];
    NSMutableArray *selectedPoints = [[NSMutableArray alloc] init];
    
    // pull the indexed objects from the common points and place into an array
    for (NSNumber *index in selectedIndices){
        [selectedPoints addObject:[commonPoints objectAtIndex:[index intValue]]];
    }
    // remove all points from selected graphs that have the same attributes
    [EDCoreDataUtility removeCommonPointsforSelectedGraphsMatchingPoints:selectedPoints context:_context];
}

#pragma mark equation sheet
- (IBAction)addNewEquation:(id)sender{
    [NSApp beginSheet:[equationController window] modalForWindow:[[self view] window] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
    _currentSheet = [equationController window];
    [equationController initializeSheet:nil index:EDEquationSheetIndexInvalid];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [[equationController window] orderOut:self];
}

- (IBAction)removeEquation:(id)sender{
    // get all selected points and their attributes
    NSMutableArray *selectedIndices = [[NSMutableArray alloc] init];
    NSIndexSet *selectedIndexSet = [tableEquation selectedRowIndexes];
    
    [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [selectedIndices addObject:[[NSNumber alloc] initWithInt:(int)idx]];
    }];
    
    // get all the common points
    NSArray *commonEquations = [EDCoreDataUtility getCommonEquationsforSelectedGraphs:_context];
    NSMutableArray *selectedEquations = [[NSMutableArray alloc] init];
    
    // pull the indexed objects from the common points and place into an array
    for (NSNumber *index in selectedIndices){
        [selectedEquations addObject:[commonEquations objectAtIndex:[index intValue]]];
    }
    // remove all points from selected graphs that have the same attributes
    [EDCoreDataUtility removeCommonEquationsforSelectedGraphsMatchingEquations:selectedEquations context:_context];
}

- (IBAction)exportEquation:(id)sender{
    // get all selected points and their attributes
    NSMutableArray *selectedIndices = [[NSMutableArray alloc] init];
    NSIndexSet *selectedIndexSet = [tableEquation selectedRowIndexes];
    
    [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [selectedIndices addObject:[[NSNumber alloc] initWithInt:(int)idx]];
    }];
    
    NSArray *commonEquations = [EDCoreDataUtility getCommonEquationsforSelectedGraphs:_context];
    NSMutableArray *selectedEquations = [[NSMutableArray alloc] init];
    NSString *newEquation;
    
    // pull the indexed objects from the common points and place into an array
    for (NSNumber *index in selectedIndices){
        newEquation = [NSString stringWithFormat:@"y=%@",[(EDEquation *)[commonEquations objectAtIndex:[index intValue]] equation]];
        [selectedEquations addObject:newEquation];
    }
    [self addNewExpressions:selectedEquations];
}

- (void)onDoubleClickEquation:(id)sender{
    // only allow double click on equation
    if ([(NSTableView *)sender clickedColumn] != 0) {
        return;
    }
    NSArray *commonEquations = [EDCoreDataUtility getCommonEquationsforSelectedGraphs:_context];
    
    // return value based on column identifier
    [NSApp beginSheet:[equationController window] modalForWindow:[[self view] window] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
    _currentSheet = [equationController window];
    //NSString *equation = [[commonEquations objectAtIndex:[(NSTableView *)sender clickedRow]] equation];
    EDEquation *equation = [commonEquations objectAtIndex:[(NSTableView *)sender clickedRow]];
    [equationController initializeSheet:equation index:(int)[(NSTableView *)sender clickedRow]];
}

#pragma mark equation
- (void)addNewExpressions:(NSArray *)expressions{
    // create new expression
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    EDExpression *newExpression;
    int i=0;
    
    // deselect everything
    [EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context];
    
    for (NSString *expression in expressions){
        newExpression = [[EDExpression alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameExpression inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
        
        // add expression to page
        [currentPage addExpressionsObject:newExpression];
        
        // set expression attributes
        [newExpression setPage:currentPage];
        [newExpression setSelected:TRUE];
        [newExpression setLocationX:50+i*20];
        [newExpression setLocationY:150+i*20];
        [newExpression setElementWidth:EDExpressionDefaultWidth];
        [newExpression setElementHeight:EDExpressionDefaultHeight];
        [newExpression setFontSize:EDExpressionDefaultFontSize];
        
        // enter default text
        [newExpression setExpression:expression];
        i++;
    }
    
    // select this graph and deselect everything else
    //[EDCoreDataUtility deselectAllSelectedWorksheetElementsOnCurrentPage:_context selectElement:newExpression];
    
}


#pragma mark graph points

#pragma mark graph error sheet
- (void)didEndSheetGraphErrorMinX:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [[graphErrorController window] orderOut:self];
    [[[self view] window] makeFirstResponder:labelMinX];
    _currentSheet = nil;
    
    // clear saved object
    _controlTextObj = nil;
}

- (void)didEndSheetGraphErrorMaxX:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [[graphErrorController window] orderOut:self];
    [[[self view] window] makeFirstResponder:labelMaxX];
    _currentSheet = nil;
    
    // clear saved object
    _controlTextObj = nil;
}

- (void)didEndSheetGraphErrorMinY:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [[graphErrorController window] orderOut:self];
    [[[self view] window] makeFirstResponder:labelMinY];
    _currentSheet = nil;
    
    // clear saved object
    _controlTextObj = nil;
}

- (void)didEndSheetGraphErrorMaxY:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [[graphErrorController window] orderOut:self];
    [[[self view] window] makeFirstResponder:labelMaxY];
    _currentSheet = nil;
    
    // clear saved object
    _controlTextObj = nil;
}

- (void)didEndSheetGraphErrorScaleX:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [[graphErrorController window] orderOut:self];
    [[[self view] window] makeFirstResponder:labelScaleX];
    _currentSheet = nil;
    
    // clear saved object
    _controlTextObj = nil;
}

- (void)didEndSheetGraphErrorScaleY:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [[graphErrorController window] orderOut:self];
    [[[self view] window] makeFirstResponder:labelScaleY];
    _currentSheet = nil;
    
    // clear saved object
    _controlTextObj = nil;
}

- (void)didEndSheetGraphErrorLabelIntervalX:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [[graphErrorController window] orderOut:self];
    [[[self view] window] makeFirstResponder:labelIntervalX];
    _currentSheet = nil;
    
    // clear saved object
    _controlTextObj = nil;
}

- (void)didEndSheetGraphErrorLabelIntervalY:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [[graphErrorController window] orderOut:self];
    [[[self view] window] makeFirstResponder:labelIntervalY];
    _currentSheet = nil;
    
    // clear saved object
    _controlTextObj = nil;
}
@end
