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

@interface EDPanelPropertiesGraphController ()
- (void)setElementLabel:(NSTextField *)label attribute:(NSString *)attribute;
- (void)setElementHasCoordinateAxes;
- (void)setElementCheckbox:(NSButton *)checkbox attribute:(NSString *)attribute;
- (void)setLabelState:(NSTextField *)label hasChange:(BOOL)diff value:(float)labelValue;
- (void)changeSelectedElementsAttribute:(NSString *)key newValue:(id)newValue;
- (NSMutableDictionary *)checkForSameFloatValueInLabelsForKey:(NSString *)key;
- (NSMutableDictionary *)checkForSameBoolValueInLabelsForKey:(NSString *)key;
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

- (void)initWindowAfterLoaded{
    // this method will only be called if only graphs are shown
    // get all of the graphs selected
    [self setElementLabel:labelHeight attribute:EDElementAttributeHeight];
    [self setElementLabel:labelWidth attribute:EDElementAttributeWidth];
    [self setElementLabel:labelX attribute:EDElementAttributeLocationX];
    [self setElementLabel:labelY attribute:EDElementAttributeLocationY];
    [self setElementHasCoordinateAxes];
    [self setElementCheckbox:checkboxGrid attribute:EDGraphAttributeGridLines];
    [self setElementCheckbox:checkboxHasTickMarks attribute:EDGraphAttributeTickMarks];
    
    // set button state
    if ([tablePoints numberOfSelectedRows] == 0) {
        [buttonRemovePoints setEnabled:FALSE];
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
#warning need to set tick marks checkbox as well
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
    NSMutableArray *elements = [_coreData getAllSelectedWorksheetElements];
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
    NSArray *graphs = [EDGraph findAllSelectedObjects];
    BOOL diff = FALSE;
    int i = 0;
    float value = 0;
    EDElement *currentElement;
    
#warning add other elements here
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

- (NSMutableDictionary *)checkForSameBoolValueInLabelsForKey:(NSString *)key{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    NSArray *graphs = [EDGraph findAllSelectedObjects];
    BOOL diff = FALSE;
    int i = 0;
    float value = 0;
    EDElement *currentElement;
    
#warning add other elements here
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
    }
    else if([checkboxHasCoordinates state] == NSOnState){
        [checkboxHasTickMarks setEnabled:TRUE];
    }
    else if([checkboxHasCoordinates state] == NSMixedState){
        [checkboxHasCoordinates setState:NSOnState];
        [checkboxHasTickMarks setEnabled:TRUE];
    }
    
    [self changeSelectedElementsAttribute:EDGraphAttributeCoordinateAxes newValue:[[NSNumber alloc] initWithBool:[checkboxHasCoordinates state]]];
}

- (IBAction)toggleHasTickMarks:(id)sender{
    // if toggle then set state to on
    if([checkboxHasTickMarks state] == NSMixedState)
        [checkboxHasTickMarks setState:NSOnState];
    
    
    [self changeSelectedElementsAttribute:EDGraphAttributeTickMarks newValue:[[NSNumber alloc] initWithBool:[checkboxHasTickMarks state]]];
}

#pragma mark graph points
- (IBAction)addNewPoint:(id)sender{
    // get currently selected graphs
    NSArray *selectedGraphs = [EDGraph findAllSelectedObjects];
    
    // create new point for each graph
    for (EDGraph *graph in selectedGraphs){
        EDPoint *newPoint = [[EDPoint alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePoint inManagedObjectContext:[_coreData context]] insertIntoManagedObjectContext:[_coreData context]];
        // set relationship
        [graph addPointsObject:newPoint];
    }
}

- (IBAction)removePoints:(id)sender{
    // get all selected points and their attributes
    NSMutableArray *selectedIndices = [[NSMutableArray alloc] init];
    NSIndexSet *selectedIndexSet = [tablePoints selectedRowIndexes];
    
    [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [selectedIndices addObject:[[NSNumber alloc] initWithInt:idx]];
    }];
    
    // get all the common points
    NSArray *commonPoints = [[EDCoreDataUtility sharedCoreDataUtility] getAllCommonPointsforSelectedGraphs];
    NSMutableArray *selectedPoints = [[NSMutableArray alloc] init];
    
    // pull the indexed objects from the common points and place into an array
    for (NSNumber *index in selectedIndices){
        [selectedPoints addObject:[commonPoints objectAtIndex:[index intValue]]];
    }
    // remove all points from selected graphs that have the same attributes
    [[EDCoreDataUtility sharedCoreDataUtility] removeCommonPointsforSelectedGraphsMatchingPoints:selectedPoints];
    
}
@end
