//
//  EDPanelPropertiesGraphController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesGraphController.h"
#import "EDGraph.h"
#import "EDPoint.h"
#import "EDElement.h"
#import "EDConstants.h"
#import "NSObject+Document.h"
#import "NSColor+Utilities.h"
#import "NSManagedObject+EasyFetching.h"
#import "EDCoreDataUtility+Points.h"
#import "EDCoreDataUtility+Equations.h"
#import "EDCoreDataUtility+Worksheet.h"

@interface EDPanelPropertiesGraphController ()
- (void)setElementLabel:(NSTextField *)label attribute:(NSString *)attribute;
- (void)setGraphPopUpValues;
- (void)setElementCheckbox:(NSButton *)checkbox attribute:(NSString *)attribute;
- (void)setLabelState:(NSTextField *)label hasChange:(BOOL)diff value:(float)labelValue;
- (void)changeSelectedElementsAttribute:(NSString *)key newValue:(id)newValue;
- (NSMutableDictionary *)checkForSameFloatValueInLabelsForKey:(NSString *)key;
- (NSMutableDictionary *)checkForSameBoolValueInLabelsForKey:(NSString *)key;
- (NSMutableDictionary *)checkForSameIntValueInLabelsForKey:(NSString *)key;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (NSArray *)maxValuesWithoutZero;
- (NSArray *)maxValuesWithMixed;
- (NSArray *)maxValues;
- (NSArray *)minValuesWithoutZero;
- (NSArray *)minValuesWithMixed;
- (NSArray *)minValues;
- (void)setPopUpButton:(NSPopUpButton *)button info:(NSMutableDictionary *)dict oppositeButton:(NSPopUpButton *)oppositeButton;
@end

@implementation EDPanelPropertiesGraphController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // init
    }
    
    return self;
}

- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context{
    _context = context;
    if (!equationController) {
        equationController = [[EDSheetPropertiesGraphEquationController alloc] initWithContext:_context];
        NSLog(@"creating equation controller.");
    }
    // this method will only be called if only graphs are shown
    // get all of the graphs selected
    [self setElementLabel:labelHeight attribute:EDElementAttributeHeight];
    [self setElementLabel:labelWidth attribute:EDElementAttributeWidth];
    [self setElementLabel:labelX attribute:EDElementAttributeLocationX];
    [self setElementLabel:labelY attribute:EDElementAttributeLocationY];
    [self setGraphPopUpValues];
    [self setElementCheckbox:checkboxHasCoordinates attribute:EDGraphAttributeCoordinateAxes];
    [self setElementCheckbox:checkboxHasLabels attribute:EDGraphAttributeLabels];
    [self setElementCheckbox:checkboxGrid attribute:EDGraphAttributeGridLines];
    [self setElementCheckbox:checkboxHasTickMarks attribute:EDGraphAttributeTickMarks];
    
    // initialize table points datasource and delegate
    tablePointsController = [[EDPanelPropertiesGraphTablePoints alloc] initWithContext:_context table:tablePoints removeButton:buttonRemovePoints];
    [tablePoints setDelegate:tablePointsController];
    [tablePoints setDataSource:tablePointsController];
    
    // set button state
    if ([tablePoints numberOfSelectedRows] == 0) {
        [buttonRemovePoints setEnabled:FALSE];
    }
    
    // initialize table equation datasource and delegate
    tableEquationController = [[EDPanelPropertiesGraphTableEquation alloc] initWithContext:_context table:tableEquation removeButton:buttonRemoveEquation];
    [tableEquation setDelegate:tableEquationController];
    [tableEquation setDataSource:tableEquationController];
    
    // set button state
    if ([tableEquation numberOfSelectedRows] == 0) {
        [buttonRemoveEquation setEnabled:FALSE];
    }
}

#pragma mark keyboard
- (void)keyDown:(NSEvent *)theEvent{
    NSLog(@"key down.");
}

#pragma mark labels
- (void)setElementLabel:(NSTextField *)label attribute:(NSString *)attribute{
    // find if there are differences in values of selected objects
    NSMutableDictionary *results = [self checkForSameFloatValueInLabelsForKey:attribute];
    
    // set label state
    [self setLabelState:label hasChange:[[results valueForKey:EDKeyDiff] boolValue] value:[[results valueForKey:EDKeyValue] floatValue]];
}

- (void)setElementCheckbox:(NSButton *)checkbox attribute:(NSString *)attribute{
    // find if there are differences in values of selected objects
    NSMutableDictionary *results = [self checkForSameBoolValueInLabelsForKey:attribute];
    
    // set state
    if ([[results valueForKey:EDKeyDiff] boolValue]) {
        [checkbox setState:NSMixedState];
    }
    else {
        if ([[results valueForKey:EDKeyValue] boolValue]) 
            [checkbox setState:NSOnState];
        else
            [checkbox setState:NSOffState];
    }
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

#pragma mark validate label state
- (void)setLabelState:(NSTextField *)label hasChange:(BOOL)diff value:(float)labelValue{
    // if there is a diff then label shows nothing, otherwise show width
    if (diff) {
        [label setStringValue:@""];
        [label setTextColor:[NSColor colorWithHexColorString:@"dddddd"]];
    }
    else {
        [label setStringValue:[NSString stringWithFormat:@"%.2f", labelValue]];
        [label setTextColor:[NSColor blackColor]];
    }
}

- (void)changeSelectedElementsAttribute:(NSString *)key newValue:(id)newValue{
    EDElement *newElement, *currentElement;
    int i = 0;
    NSMutableArray *elements = [EDCoreDataUtility getAllSelectedWorksheetElements:_context];
    while (i < [elements count]) {
     currentElement = [elements objectAtIndex:i];
        
        newElement = currentElement;
        [newElement setValue:newValue forKey:key];
        
        [elements replaceObjectAtIndex:i withObject:newElement];
        i++;
    }
}

- (NSMutableDictionary *)checkForSameFloatValueInLabelsForKey:(NSString *)key{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    NSArray *graphs = [EDGraph getAllSelectedObjects:_context];
    BOOL diff = FALSE;
    int i = 0;
    float value = 0;
    EDElement *currentElement;
    
    [elements addObjectsFromArray:graphs];
    while ((i < [elements count]) && (!diff)) {
        currentElement = [elements objectAtIndex:i];
        // if not the first and current width is not the same as previous width
        if((i != 0) && (value != [[currentElement valueForKey:key] floatValue])){
            diff = TRUE;
        }
        else {
            value = [[currentElement valueForKey:key] floatValue];
        }
        i++;
    }
    
    // set results
    [results setValue:[[NSNumber alloc] initWithFloat:value] forKey:EDKeyValue];
    [results setValue:[[NSNumber alloc] initWithBool:diff] forKey:EDKeyDiff];
    return results;
}

- (NSMutableDictionary *)checkForSameIntValueInLabelsForKey:(NSString *)key{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    NSArray *graphs = [EDGraph getAllSelectedObjects:_context];
    BOOL diff = FALSE;
    int i = 0;
    float value = 0;
    EDElement *currentElement;
    
#warning add other elements here
    [elements addObjectsFromArray:graphs];
    while ((i < [elements count]) && (!diff)) {
        currentElement = [elements objectAtIndex:i];
        // if not the first and current width is not the same as previous width
        if((i != 0) && (value != [[currentElement valueForKey:key] intValue])){
            diff = TRUE;
        }
        else {
            value = [[currentElement valueForKey:key] intValue];
        }
        i++;
    }
    
    // set results
    [results setValue:[[NSNumber alloc] initWithFloat:value] forKey:EDKeyValue];
    [results setValue:[[NSNumber alloc] initWithBool:diff] forKey:EDKeyDiff];
    return results;
}

- (NSMutableDictionary *)checkForSameBoolValueInLabelsForKey:(NSString *)key{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    NSArray *graphs = [EDGraph getAllSelectedObjects:_context];
    BOOL diff = FALSE;
    int i = 0;
    float value = 0;
    EDElement *currentElement;
    
    [elements addObjectsFromArray:graphs];
    while ((i < [elements count]) && (!diff)) {
        currentElement = [elements objectAtIndex:i];
        // if not the first and current width is not the same as previous width
        if((i != 0) && (value != [[currentElement valueForKey:key] boolValue])){
            diff = TRUE;
        }
        else {
            value = [[currentElement valueForKey:key] boolValue];
        }
        i++;
    }
    
    // set results
    [results setValue:[[NSNumber alloc] initWithBool:value] forKey:EDKeyValue];
    [results setValue:[[NSNumber alloc] initWithBool:diff] forKey:EDKeyDiff];
    return results;
}

#pragma mark text field delegation
- (void)controlTextDidEndEditing:(NSNotification *)obj{
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
    [equationController initializeSheet:TRUE];
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
#pragma mark graph points

#pragma mark min/max values
- (NSArray *)minValuesWithoutZero{
   return [NSArray arrayWithObjects:[[NSNumber numberWithInt:-1] stringValue],[[NSNumber numberWithInt:-5] stringValue],[[NSNumber numberWithInt:-10] stringValue],[[NSNumber numberWithInt:-25] stringValue],[[NSNumber numberWithInt:-100] stringValue],[[NSNumber numberWithInt:-1000] stringValue], nil];
}

- (NSArray *)minValuesWithMixed{
   return [NSArray arrayWithObjects:[NSString stringWithFormat:@""], [[NSNumber numberWithInt:0] stringValue],[[NSNumber numberWithInt:-1] stringValue],[[NSNumber numberWithInt:-5] stringValue],[[NSNumber numberWithInt:-10] stringValue],[[NSNumber numberWithInt:-25] stringValue],[[NSNumber numberWithInt:-100] stringValue],[[NSNumber numberWithInt:-1000] stringValue], nil];
}

- (NSArray *)minValues{
   return [NSArray arrayWithObjects:[[NSNumber numberWithInt:0] stringValue],[[NSNumber numberWithInt:-1] stringValue],[[NSNumber numberWithInt:-5] stringValue],[[NSNumber numberWithInt:-10] stringValue],[[NSNumber numberWithInt:-25] stringValue],[[NSNumber numberWithInt:-100] stringValue],[[NSNumber numberWithInt:-1000] stringValue], nil];
}

- (NSArray *)maxValues{
    return [NSArray arrayWithObjects:[[NSNumber numberWithInt:0] stringValue],[[NSNumber numberWithInt:1] stringValue],[[NSNumber numberWithInt:5] stringValue],[[NSNumber numberWithInt:10] stringValue],[[NSNumber numberWithInt:25] stringValue],[[NSNumber numberWithInt:100] stringValue],[[NSNumber numberWithInt:1000] stringValue], nil];
}

- (NSArray *)maxValuesWithoutZero{
    return [NSArray arrayWithObjects:[[NSNumber numberWithInt:1] stringValue],[[NSNumber numberWithInt:5] stringValue],[[NSNumber numberWithInt:10] stringValue],[[NSNumber numberWithInt:25] stringValue],[[NSNumber numberWithInt:100] stringValue],[[NSNumber numberWithInt:1000] stringValue], nil];
}

- (NSArray *)maxValuesWithMixed{
    return [NSArray arrayWithObjects:[NSString stringWithFormat:@""], [[NSNumber numberWithInt:0] stringValue],[[NSNumber numberWithInt:1] stringValue],[[NSNumber numberWithInt:5] stringValue],[[NSNumber numberWithInt:10] stringValue],[[NSNumber numberWithInt:25] stringValue],[[NSNumber numberWithInt:100] stringValue],[[NSNumber numberWithInt:1000] stringValue], nil];
}

- (void)setGraphPopUpValues{
    // find if there are differences in values of selected objects
    NSMutableDictionary *resultsMinX = [self checkForSameIntValueInLabelsForKey:EDGraphAttributeMinValueX];
    NSMutableDictionary *resultsMinY = [self checkForSameIntValueInLabelsForKey:EDGraphAttributeMinValueY];
    NSMutableDictionary *resultsMaxX = [self checkForSameIntValueInLabelsForKey:EDGraphAttributeMaxValueX];
    NSMutableDictionary *resultsMaxY = [self checkForSameIntValueInLabelsForKey:EDGraphAttributeMaxValueY];
    
    // add items to buttons
    [buttonMinX removeAllItems];
    [buttonMinX addItemsWithTitles:[self minValues]];
    [buttonMinY removeAllItems];
    [buttonMinY addItemsWithTitles:[self minValues]];
    [buttonMaxX removeAllItems];
    [buttonMaxX addItemsWithTitles:[self maxValues]];
    [buttonMaxY removeAllItems];
    [buttonMaxY addItemsWithTitles:[self maxValues]];
    
    // set state based on pop up buttons
    [self setPopUpButton:buttonMinX info:resultsMinX oppositeButton:buttonMaxX];
    [self setPopUpButton:buttonMaxX info:resultsMaxX oppositeButton:buttonMinX];
    [self setPopUpButton:buttonMinY info:resultsMinY oppositeButton:buttonMaxY];
    [self setPopUpButton:buttonMaxY info:resultsMaxY oppositeButton:buttonMinY];
}

- (void)setPopUpButton:(NSPopUpButton *)button info:(NSMutableDictionary *)dict oppositeButton:(NSPopUpButton *)oppositeButton{
    if ([[dict valueForKey:EDKeyDiff] boolValue]) {
        // add mixed value to pop up list
        [button insertItemWithTitle:@"" atIndex:0];
        
        // set mixed value
        [button selectItem:[button itemAtIndex:[button indexOfItemWithTitle:@""]]];
    }
    else {
        if ([[dict valueForKey:EDKeyValue] intValue] == 0) {
            // if button is equal to 0 then the opposite button cannot have the option of being 0
            [oppositeButton removeItemWithTitle:@"0"];
        }
        
        // automatically set button value to graph max/min value
        [button selectItem:[button itemAtIndex:[button indexOfItemWithTitle:[NSString stringWithFormat:@"%d",[[dict valueForKey:EDKeyValue] intValue]]]]];
        //[button selectItem:[button itemAtIndex:[button indexOfItemWithTitle:[NSString stringWithFormat:@"%d",0]]]];
    }
}

- (IBAction)changeValueMinX:(id)sender{
    // do nothing if mixed value selected
    if ([[[buttonMinX selectedItem] title] isEqualToString:@""])
        return;
    
    [self changeSelectedElementsAttribute:EDGraphAttributeMinValueX newValue:[NSNumber numberWithInt:[[[buttonMinX selectedItem] title] intValue]]];
}

- (IBAction)changeValueMinY:(id)sender{
    // do nothing if mixed value selected
    if ([[[buttonMinY selectedItem] title] isEqualToString:@""])
        return;
    
    [self changeSelectedElementsAttribute:EDGraphAttributeMinValueY newValue:[NSNumber numberWithInt:[[[buttonMinY selectedItem] title] intValue]]];
}

- (IBAction)changeValueMaxX:(id)sender{
    // do nothing if mixed value selected
    if ([[[buttonMaxX selectedItem] title] isEqualToString:@""])
        return;
    
    [self changeSelectedElementsAttribute:EDGraphAttributeMaxValueX newValue:[NSNumber numberWithInt:[[[buttonMaxX selectedItem] title] intValue]]];
}

- (IBAction)changeValueMaxY:(id)sender{
    // do nothing if mixed value selected
    if ([[[buttonMaxY selectedItem] title] isEqualToString:@""])
        return;
    
    [self changeSelectedElementsAttribute:EDGraphAttributeMaxValueY newValue:[NSNumber numberWithInt:[[[buttonMaxY selectedItem] title] intValue]]];
}
@end
