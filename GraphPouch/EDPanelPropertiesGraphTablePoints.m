//
//  EDPanelPropertiesGraphTablePoints.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesGraphTablePoints.h"
#import "EDCoreDataUtility.h"
#import "EDPoint.h"
#import "NSMutableArray+Utilities.h"

@interface EDPanelPropertiesGraphTablePoints()
- (void)onContextChanged:(NSNotification *)note;
@end

@implementation EDPanelPropertiesGraphTablePoints

- (id)init{
    self = [super init];
    if (self){
        // init
        _context = [[EDCoreDataUtility sharedCoreDataUtility] context];
        NSLog(@"init");
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    NSLog(@"number of rows");
    NSMutableArray *commonPointsForSelectedGraphs = [[EDCoreDataUtility sharedCoreDataUtility] getAllCommonPointsforSelectedGraphs];
    if (!commonPointsForSelectedGraphs) {
        return 0;
    }
    return [commonPointsForSelectedGraphs count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    // the return value is typed as (id) because it will return a string in all cases with the exception of the
    id returnValue=nil;
    
    // The column identifier string is the easiest way to identify a table column. Much easier
    // than keeping a reference to the table column object.
    NSString *columnIdentifier = [tableColumn identifier];
    
    // Get common points
    NSMutableArray *commonPointsForSelectedGraphs = [[EDCoreDataUtility sharedCoreDataUtility] getAllCommonPointsforSelectedGraphs];
    NSMutableArray *commonPoints = [[NSMutableArray alloc] init];
    
    // return if empty
    if (!commonPointsForSelectedGraphs) {
        return nil;
    }
    
    // populate array
    for (EDPoint *point in commonPointsForSelectedGraphs){
        //[commonPoints addObject:[commonPointsForSelectedGraphs objectForKey:key]];
        [commonPoints addObject:point];
    }
    
    // sort
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationX" ascending:TRUE];
    NSArray *descriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSArray *sortedArray = [commonPoints sortedArrayUsingDescriptors:descriptorArray];
    
    // return value based on column identifier
    if ([columnIdentifier isEqualToString:@"x"]) {
        returnValue = [[NSNumber alloc] initWithFloat:[(EDPoint *)[sortedArray objectAtIndex:row] locationX]];
    }
    else if ([columnIdentifier isEqualToString:@"y"]) {
        returnValue = [[NSNumber alloc] initWithFloat:[(EDPoint *)[sortedArray objectAtIndex:row] locationX]];
    }
    else if ([columnIdentifier isEqualToString:@"visible"]) {
        returnValue = [[NSNumber alloc] initWithBool:[(EDPoint *)[sortedArray objectAtIndex:row] isVisible]];
    }
    
    
    return returnValue; 
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    id newValue;
    
    // The column identifier string is the easiest way to identify a table column. Much easier
    // than keeping a reference to the table column object.
    NSString *columnIdentifier = [tableColumn identifier];
    
    // Get common points
    NSMutableArray *commonPointsForSelectedGraphs = [[EDCoreDataUtility sharedCoreDataUtility] getAllCommonPointsforSelectedGraphs];
    NSMutableArray *commonPoints = [[NSMutableArray alloc] init];
    
    // populate array
    for (EDPoint *point in commonPointsForSelectedGraphs){
        //[commonPoints addObject:[commonPointsForSelectedGraphs objectForKey:key]];
        [commonPoints addObject:point];
    }
    
    // sort
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationX" ascending:TRUE];
    NSArray *descriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSArray *sortedArray = [commonPoints sortedArrayUsingDescriptors:descriptorArray];
    
    
    // set attribute of EDPoint
    if ([columnIdentifier isEqualToString:@"x"]) {
        newValue = [[NSNumber alloc] initWithFloat:[(EDPoint *)[sortedArray objectAtIndex:row] locationX]];
        [(EDPoint *)[sortedArray objectAtIndex:row] setLocationX:[newValue floatValue]];
    }
    else if ([columnIdentifier isEqualToString:@"y"]) {
        newValue = [[NSNumber alloc] initWithFloat:[(EDPoint *)[sortedArray objectAtIndex:row] locationX]];
        [(EDPoint *)[sortedArray objectAtIndex:row] setLocationX:[newValue floatValue]];
    }
    else if ([columnIdentifier isEqualToString:@"visible"]) {
        newValue = [[NSNumber alloc] initWithBool:[(EDPoint *)[sortedArray objectAtIndex:row] isVisible]];
        [(EDPoint *)[sortedArray objectAtIndex:row] setIsVisible:[newValue boolValue]];
    }
    
}

#pragma mark table delegate
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSLog(@"table view selction did change.");
}

- (void)onContextChanged:(NSNotification *)note{
    [pointsTable reloadData];
    //NSLog(@"context changed.");
}
@end
