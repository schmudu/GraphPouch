//
//  EDPanelPropertiesGraphTableEquation.m
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesGraphTableEquation.h"
#import "EDCoreDataUtility.h"
#import "EDConstants.h"
#import "EDCoreDataUtility+Equations.h"
#import "EDEquation.h"
#import "NSColor+Utilities.h"

@interface EDPanelPropertiesGraphTableEquation()
- (void)onContextChanged:(NSNotification *)note;
@end

@implementation EDPanelPropertiesGraphTableEquation
- (id)initWithContext:(NSManagedObjectContext *)context table:(NSTableView *)table removeButton:(NSButton *)removeButton exportButton:(NSButton *)exportButton{
    self = [super init];
    if (self){
        // init
        _context = context;
        equationTable = table;
        buttonEquationRemove = removeButton;
        buttonEquationExport = exportButton;
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    NSArray *commonEquationsForSelectedGraphs = [EDCoreDataUtility getCommonEquationsforSelectedGraphs:_context];
    if (!commonEquationsForSelectedGraphs) {
        return 0;
    }
    return [commonEquationsForSelectedGraphs count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    // the return value is typed as (id) because it will return a string in all cases with the exception of the
    id returnValue=nil;
    
    // The column identifier string is the easiest way to identify a table column. Much easier
    // than keeping a reference to the table column object.
    NSString *columnIdentifier = [tableColumn identifier];
    
    // Get common equations
    NSArray *commonEquations = [EDCoreDataUtility getCommonEquationsforSelectedGraphs:_context];
    EDEquation *equation = (EDEquation *)[commonEquations objectAtIndex:row];
    
    // return value based on column identifier
    if ([columnIdentifier isEqualToString:@"equation"]) {
        switch ([[equation equationType] intValue]) {
            case EDEquationTypeEqual:
                returnValue = [NSString stringWithFormat:@"%@%@",EDEquationTypeStringEqual, [(EDEquation *)[commonEquations objectAtIndex:row] equation]];
                break;
            case EDEquationTypeLessThan:
                returnValue = [NSString stringWithFormat:@"%@%@",EDEquationTypeStringLessThan, [(EDEquation *)[commonEquations objectAtIndex:row] equation]];
                break;
            case EDEquationTypeLessThanOrEqual:
                returnValue = [NSString stringWithFormat:@"%@%@",EDEquationTypeStringLessThanOrEqual, [(EDEquation *)[commonEquations objectAtIndex:row] equation]];
                break;
            case EDEquationTypeGreaterThan:
                returnValue = [NSString stringWithFormat:@"%@%@",EDEquationTypeStringGreaterThan, [(EDEquation *)[commonEquations objectAtIndex:row] equation]];
                break;
            case EDEquationTypeGreaterThanOrEqual:
                returnValue = [NSString stringWithFormat:@"%@%@",EDEquationTypeStringGreaterThanOrEqual, [(EDEquation *)[commonEquations objectAtIndex:row] equation]];
                break;
            default:
                returnValue = [NSString stringWithFormat:@"%@%@",EDEquationTypeStringEqual, [(EDEquation *)[commonEquations objectAtIndex:row] equation]];
                break;
        }
    }
    else if ([columnIdentifier isEqualToString:@"visible"]) {
        if (![(EDEquation *)[commonEquations objectAtIndex:row] matchesHaveSameVisibility]) {
            // if all graphs don't have same property then show mixed state
            returnValue = [[NSNumber alloc] initWithInt:NSMixedState];
        }
        else {
            returnValue = [[NSNumber alloc] initWithBool:[equation isVisible]];
        }
    }
    else if ([columnIdentifier isEqualToString:@"color"]) {
        if(([[equation equationType] intValue] == EDEquationTypeGreaterThan) ||
            ([[equation equationType] intValue] == EDEquationTypeGreaterThanOrEqual) ||
            ([[equation equationType] intValue] == EDEquationTypeLessThan) ||
            ([[equation equationType] intValue] == EDEquationTypeLessThanOrEqual)){
            NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(19, 19)];
            
            // draw color box
            [image lockFocus];
            [[NSColor blackColor] setStroke];
            [(NSColor *)[equation inequalityColor] setFill];
            [NSBezierPath fillRect:NSMakeRect(2, 2, 15, 15)];
            [image unlockFocus];
            
            returnValue = image;
        }
    }
    else if ([columnIdentifier isEqualToString:@"alpha"]) {
        if(([[equation equationType] intValue] == EDEquationTypeGreaterThan) ||
            ([[equation equationType] intValue] == EDEquationTypeGreaterThanOrEqual) ||
            ([[equation equationType] intValue] == EDEquationTypeLessThan) ||
            ([[equation equationType] intValue] == EDEquationTypeLessThanOrEqual)){
            if (!alphaFormatter){
                alphaFormatter = [[EDFormatterDecimalUnsigned alloc] init];
            }
            [[[tableView tableColumnWithIdentifier:@"alpha"] dataCell] setFormatter:alphaFormatter];
            
            returnValue = [NSString stringWithFormat:@"%f", [equation inequalityAlpha]];
        }
        else{
            [[[tableView tableColumnWithIdentifier:@"alpha"] dataCell] setFormatter:nil];
            returnValue = [NSString stringWithFormat:@""];
        }
    }
    
    
    return returnValue; 
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    // The column identifier string is the easiest way to identify a table column. Much easier
    // than keeping a reference to the table column object.
    NSString *columnIdentifier = [tableColumn identifier];
    
    // Get common points
    NSArray *commonEquations = [EDCoreDataUtility getCommonEquationsforSelectedGraphs:_context];
    
    // set attribute of EDEquation
    EDEquation *currentEquation = (EDEquation *)[commonEquations objectAtIndex:row];
    EDEquation *newEquation = [[EDEquation alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNameEquation inManagedObjectContext:_context] insertIntoManagedObjectContext:nil];
    NSMutableDictionary *newAttribute = [[NSMutableDictionary alloc] init];
    
    [newEquation copyAttributes:currentEquation];
    
    if ([columnIdentifier isEqualToString:@"visible"]) {
        [newAttribute setValue:EDEquationAttributeIsVisible forKey:EDKey];
        [newAttribute setObject:object forKey:EDValue];
    }
    
    // set the attribute for the graph that holds this point
    // set the common points
    //[EDCoreDataUtility setAllCommonPointsforSelectedGraphs:newPoint attribute:newAttribute context:_context];
    [EDCoreDataUtility setAllCommonEquationsforSelectedGraphs:newEquation attribute:newAttribute context:_context];
}

#pragma mark table delegate
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    // if nothing selected
    if ([equationTable numberOfSelectedRows] == 0) {
        [buttonEquationRemove setEnabled:FALSE];
        [buttonEquationExport setEnabled:FALSE];
    }
    else{
        [buttonEquationRemove setEnabled:TRUE];
        [buttonEquationExport setEnabled:TRUE];
    }
}

- (void)onContextChanged:(NSNotification *)note{
    [equationTable reloadData];
}

@end
