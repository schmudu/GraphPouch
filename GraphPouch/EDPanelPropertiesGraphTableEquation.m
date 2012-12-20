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

@interface EDPanelPropertiesGraphTableEquation()
- (void)onContextChanged:(NSNotification *)note;
@end

@implementation EDPanelPropertiesGraphTableEquation
- (id)initWithContext:(NSManagedObjectContext *)context table:(NSTableView *)table removeButton:(NSButton *)button{
    self = [super init];
    if (self){
        // init
        _context = context;
        equationTable = table;
        buttonEquationRemove = button;
        
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
    
    // return value based on column identifier
    if ([columnIdentifier isEqualToString:@"equation"]) {
        returnValue = [NSString stringWithFormat:@"%@",[(EDEquation *)[commonEquations objectAtIndex:row] equation]];
    }
    else if ([columnIdentifier isEqualToString:@"visible"]) {
        if (![(EDEquation *)[commonEquations objectAtIndex:row] matchesHaveSameVisibility]) {
            // if all graphs don't have same property then show mixed state
            returnValue = [[NSNumber alloc] initWithInt:NSMixedState];
        }
        else {
            returnValue = [[NSNumber alloc] initWithBool:[(EDEquation *)[commonEquations objectAtIndex:row] isVisible]];
        }
    }
    else if ([columnIdentifier isEqualToString:@"label"]) {
        if (![(EDEquation *)[commonEquations objectAtIndex:row] matchesHaveSameLabel]) {
            // if all graphs don't have same property then show mixed state
            returnValue = [[NSNumber alloc] initWithInt:NSMixedState];
        }
        else {
            returnValue = [[NSNumber alloc] initWithBool:[(EDEquation *)[commonEquations objectAtIndex:row] showLabel]];
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
    
    /*
    if ([columnIdentifier isEqualToString:@"equation"]) {
        [newAttribute setValue:EDEquationAttributeEquation forKey:EDKey];
        [newAttribute setObject:object forKey:EDValue];
    }*/
    if ([columnIdentifier isEqualToString:@"visible"]) {
        [newAttribute setValue:EDEquationAttributeIsVisible forKey:EDKey];
        [newAttribute setObject:object forKey:EDValue];
    }
    else if ([columnIdentifier isEqualToString:@"label"]) {
        [newAttribute setValue:EDGraphPointAttributeShowLabel forKey:EDKey];
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
    }
    else{
        [buttonEquationRemove setEnabled:TRUE];
    }
}

- (void)onContextChanged:(NSNotification *)note{
    [equationTable reloadData];
}

@end
