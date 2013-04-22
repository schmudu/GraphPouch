//
//  EDPanelViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/10/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDCoreDataUtility+Worksheet.h"
#import "EDElement.h"
#import "EDExpression.h"
#import "EDGraph.h"
#import "EDLine.h"
#import "EDTextbox.h"
#import "EDPanelViewController.h"
#import "NSColor+Utilities.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDPanelViewController ()

@end

@implementation EDPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _context = context;
        _nc = [NSNotificationCenter defaultCenter];
        _fieldChanged = FALSE;
    }
    
    return self;
}

- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context{
    // init code, every time items change
}

- (void)loadView{
    [self viewWillLoad];
    [super loadView];
    [self viewDidLoad];
}

- (void)viewDidLoad{
    // code after view loaded
}

- (void)viewWillLoad{
    // code before view loaded
}

#pragma mark labels
- (void)setElementLabel:(NSTextField *)label attribute:(NSString *)attribute{
    // find if there are differences in values of selected objects
    NSMutableDictionary *results = [self checkForSameFloatValueInLabelsForKey:attribute];
    
    // set label state
    [self setLabelState:label hasChange:[[results valueForKey:EDKeyDiff] boolValue] value:[[results valueForKey:EDKeyValue] floatValue]];
}

- (void)setSlider:(NSSlider *)slider attribute:(NSString *)attribute{
    // find if there are differences in values of selected objects
    NSMutableDictionary *results = [self checkForSameFloatValueInLabelsForKey:attribute];
    
    // set label state
    if ([[results valueForKey:EDKeyDiff] boolValue]){
        // if there is a difference then set to default value
        [slider setDoubleValue:14.0];
    }
    else{
        // no diff set to value
        [slider setFloatValue:[[results valueForKey:EDKeyValue] floatValue]];
    }
}

- (void)setElementLabel:(NSTextField *)label withStringAttribute:(NSString *)attribute{
    // find if there are differences in values of selected objects
    //NSMutableDictionary *results = [self checkForSameFloatValueInLabelsForKey:attribute];
    NSMutableDictionary *results = [self checkForSameStringValueInLabelsForKey:attribute];
    // set label state
    [self setLabelState:label hasChange:[[results valueForKey:EDKeyDiff] boolValue] stringValue:[results valueForKey:EDKeyValue]];
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

- (void)setLabelState:(NSTextField *)label hasChange:(BOOL)diff stringValue:(NSString *)labelValue{
    // if there is a diff then label shows nothing, otherwise show width
    if (diff) {
        [label setStringValue:@""];
        [label setTextColor:[NSColor colorWithHexColorString:@"dddddd"]];
    }
    else {
        [label setStringValue:labelValue];
        [label setTextColor:[NSColor blackColor]];
    }
}

- (NSMutableDictionary *)checkForSameFloatValueInLabelsForKey:(NSString *)key{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    NSArray *elements = [currentPage getAllSelectedWorksheetObjects];
    BOOL diff = FALSE;
    int i = 0;
    float value = 0;
    EDElement *currentElement;
    
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
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    NSArray *elements = [currentPage getAllSelectedWorksheetObjects];
    BOOL diff = FALSE;
    int i = 0;
    float value = 0;
    EDElement *currentElement;
    
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
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    NSArray *elements = [currentPage getAllSelectedWorksheetObjects];
    BOOL diff = FALSE;
    int i = 0;
    float value = 0;
    EDElement *currentElement;
    
    //[elements addObjectsFromArray:graphs];
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

- (NSMutableDictionary *)checkForSameStringValueInLabelsForKey:(NSString *)key{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:_context];
    NSArray *elements = [currentPage getAllSelectedWorksheetObjects];
    BOOL diff = FALSE;
    int i = 0;
    NSString *value;
    EDElement *currentElement;
    
    //[elements addObjectsFromArray:graphs];
    while ((i < [elements count]) && (!diff)) {
        currentElement = [elements objectAtIndex:i];
        // if not the first and current width is not the same as previous width
        if((i != 0) && (![value isEqualToString:[currentElement valueForKey:key]])){
            diff = TRUE;
        }
        else {
            value = [currentElement valueForKey:key];
        }
        i++;
    }
    
    // set results
    [results setValue:[NSString stringWithString:value] forKey:EDKeyValue];
    [results setValue:[[NSNumber alloc] initWithBool:diff] forKey:EDKeyDiff];
    return results;
}

- (void)changeSelectedElementsAttribute:(NSString *)key newValue:(id)newValue{
    EDElement *newElement, *currentElement;
    int i = 0;
    NSMutableArray *elements = [EDCoreDataUtility getAllSelectedWorksheetElements:_context];
    while (i < [elements count]) {
     currentElement = [elements objectAtIndex:i];
        
        newElement = currentElement;
        
        // check if value exists
        if ([newElement respondsToSelector:NSSelectorFromString(key)]){
            [newElement setValue:newValue forKey:key];
            [elements replaceObjectAtIndex:i withObject:newElement];
        }
        i++;
    }
}

#pragma mark control text 
- (void)onControlReceivedFocus:(NSNotification *)note{
    // reset variable
    _fieldChanged = FALSE;
}

- (void)controlTextDidChange:(NSNotification *)obj{
    // if not already set, reset color to black
   [(NSTextField *)[obj object] setTextColor:[NSColor blackColor]];
    
    // text changed
    _fieldChanged = TRUE;
}
@end
