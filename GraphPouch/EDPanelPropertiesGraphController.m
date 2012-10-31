//
//  EDPanelPropertiesGraphController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesGraphController.h"
#import "EDGraph.h"
#import "EDElement.h"
#import "EDConstants.h"
#import "NSObject+Document.h"
#import "NSColor+Utilities.h"

@interface EDPanelPropertiesGraphController ()
- (void)setElementLabelHeight;
- (void)setElementLabelWidth;
- (void)setElementLabelX;
- (void)setElementLabelY;
- (void)setLabelState:(NSTextField *)label hasChange:(BOOL)diff value:(float)labelValue;
- (void)changeElementsAttributes:(float)newWidth height:(float)newHeight locationX:(float)newXPos locationY:(float)newYPos;
- (void)changeSelectedElementsAttribute:(NSString *)key newValue:(id)newValue;
- (NSMutableDictionary *)checkForSameFloatValueInLabelsForKey:(NSString *)key;
- (NSMutableDictionary *)checkForSameBoolValueInLabelsForKey:(NSString *)key;
@end

@implementation EDPanelPropertiesGraphController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)initWindowAfterLoaded{
    // this method will only be called if only graphs are shown
    // get all of the graphs selected
    //NSArray *graphs = [EDGraph findAllSelectedObjects];
    //NSLog(@"graph view did load: graphs: %@", graphs);
    [self setElementLabelHeight];
    [self setElementLabelWidth];
    [self setElementLabelX];
    [self setElementLabelY];
    [self setElementHasCoordinateAxes];
}

#pragma mark labels
- (void)setElementLabelHeight{
    // find if there are differences in values of selected objects
    NSMutableDictionary *results = [self checkForSameFloatValueInLabelsForKey:EDElementAttributeHeight];
    
    // set label state
    [self setLabelState:labelHeight hasChange:[[results valueForKey:EDKeyDiff] boolValue] value:[[results valueForKey:EDKeyValue] floatValue]];
}

- (void)setElementLabelWidth{
    // find if there are differences in values of selected objects
    NSMutableDictionary *results = [self checkForSameFloatValueInLabelsForKey:EDElementAttributeWidth];
    
    // set label state
    [self setLabelState:labelWidth hasChange:[[results valueForKey:EDKeyDiff] boolValue] value:[[results valueForKey:EDKeyValue] floatValue]];
}

- (void)setElementLabelX{
    // find if there are differences in values of selected objects
    NSMutableDictionary *results = [self checkForSameFloatValueInLabelsForKey:EDElementAttributeLocationX];
    
    // set label state
    [self setLabelState:labelX hasChange:[[results valueForKey:EDKeyDiff] boolValue] value:[[results valueForKey:EDKeyValue] floatValue]];
}

- (void)setElementLabelY{
    // find if there are differences in values of selected objects
    NSMutableDictionary *results = [self checkForSameFloatValueInLabelsForKey:EDElementAttributeLocationY];
    
    // set label state
    [self setLabelState:labelY hasChange:[[results valueForKey:EDKeyDiff] boolValue] value:[[results valueForKey:EDKeyValue] floatValue]];
}

- (void)setElementHasCoordinateAxes{
    // find if there are differences in values of selected objects
    NSMutableDictionary *results = [self checkForSameBoolValueInLabelsForKey:EDGraphAttributeCoordinateAxes];
    
    // set state
    NSLog(@"diff?%d", [[results valueForKey:EDKeyDiff] boolValue]);
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

- (void)changeElementsAttributes:(float)newWidth height:(float)newHeight locationX:(float)newXPos locationY:(float)newYPos{
    EDElement *newElement, *currentElement;
    int i = 0;
    NSMutableArray *elements = [_coreData getAllSelectedObjects];
    //for (EDElement *element in elements){
    while (i < [elements count]) {
     currentElement = [elements objectAtIndex:i];
        
        newElement = currentElement;
        [newElement setValue:[[NSNumber alloc] initWithFloat:newWidth] forKey:EDElementAttributeWidth];
        [newElement setValue:[[NSNumber alloc] initWithFloat:newHeight] forKey:EDElementAttributeHeight];
        [newElement setValue:[[NSNumber alloc] initWithFloat:newXPos] forKey:EDElementAttributeLocationX];
        [newElement setValue:[[NSNumber alloc] initWithFloat:newYPos] forKey:EDElementAttributeLocationY];
        
        [elements replaceObjectAtIndex:i withObject:newElement];
        i++;
    }
}

- (void)changeSelectedElementsAttribute:(NSString *)key newValue:(id)newValue{
    EDElement *newElement, *currentElement;
    int i = 0;
    NSMutableArray *elements = [_coreData getAllSelectedObjects];
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
            //value = [currentElement locationY];
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
    [self changeElementsAttributes:[[labelWidth stringValue] floatValue] height:[[labelHeight stringValue] floatValue] locationX:[[labelX stringValue] floatValue] locationY:[[labelY stringValue] floatValue]];
}

#pragma mark checkbox
- (IBAction)toggleHasCoordinateAxes:(id)sender{
    // if toggle then set state to on
    if([checkboxHasCoordinates state] == NSMixedState)
        [checkboxHasCoordinates setState:NSOnState];
    
    [self changeSelectedElementsAttribute:EDGraphAttributeCoordinateAxes newValue:[[NSNumber alloc] initWithBool:[checkboxHasCoordinates state]]];
}

@end
