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
#import "NSMutableArray+EDPoint.h"
#import "EDConstants.h"
#import "EDCoreDataUtility+Points.h"

@interface EDPanelPropertiesGraphTablePoints()
- (void)onContextChanged:(NSNotification *)note;
@end

@implementation EDPanelPropertiesGraphTablePoints

- (id)init{
    self = [super init];
    if (self){
        // init
        _context = [[EDCoreDataUtility sharedCoreDataUtility] context];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    NSArray *commonPointsForSelectedGraphs = [[EDCoreDataUtility sharedCoreDataUtility] getAllCommonPointsforSelectedGraphs];
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
    NSArray *commonPoints = [[EDCoreDataUtility sharedCoreDataUtility] getAllCommonPointsforSelectedGraphs];
    
    // return value based on column identifier
    if ([columnIdentifier isEqualToString:@"x"]) {
        returnValue = [[NSNumber alloc] initWithFloat:[(EDPoint *)[commonPoints objectAtIndex:row] locationX]];
    }
    else if ([columnIdentifier isEqualToString:@"y"]) {
        returnValue = [[NSNumber alloc] initWithFloat:[(EDPoint *)[commonPoints objectAtIndex:row] locationY]];
    }
    else if ([columnIdentifier isEqualToString:@"visible"]) {
        if (![(EDPoint *)[commonPoints objectAtIndex:row] matchesHaveSameVisibility]) {
            // if all graphs don't have same property then show mixed state
            returnValue = [[NSNumber alloc] initWithInt:NSMixedState];
        }
        else {
            returnValue = [[NSNumber alloc] initWithBool:[(EDPoint *)[commonPoints objectAtIndex:row] isVisible]];
        }
    }
    else if ([columnIdentifier isEqualToString:@"label"]) {
        if (![(EDPoint *)[commonPoints objectAtIndex:row] matchesHaveSameLabel]) {
            // if all graphs don't have same property then show mixed state
            returnValue = [[NSNumber alloc] initWithInt:NSMixedState];
        }
        else {
            returnValue = [[NSNumber alloc] initWithBool:[(EDPoint *)[commonPoints objectAtIndex:row] showLabel]];
        }
    }
    
    
    return returnValue; 
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    // The column identifier string is the easiest way to identify a table column. Much easier
    // than keeping a reference to the table column object.
    NSString *columnIdentifier = [tableColumn identifier];
    
    // Get common points
    NSArray *commonPoints = [[EDCoreDataUtility sharedCoreDataUtility] getAllCommonPointsforSelectedGraphs];
    
    // set attribute of EDPoint
    EDPoint *currentPoint = (EDPoint *)[commonPoints objectAtIndex:row];
    EDPoint *newPoint = [[EDPoint alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePoint inManagedObjectContext:[[EDCoreDataUtility sharedCoreDataUtility] context]] insertIntoManagedObjectContext:nil];
    NSMutableDictionary *newAttribute = [[NSMutableDictionary alloc] init];
    
    [newPoint copyAttributes:currentPoint];
    
    if ([columnIdentifier isEqualToString:@"x"]) {
        [newAttribute setValue:EDElementAttributeLocationX forKey:EDKey];
        [newAttribute setObject:object forKey:EDValue];
    }
    else if ([columnIdentifier isEqualToString:@"y"]) {
        [newAttribute setValue:EDElementAttributeLocationY forKey:EDKey];
        [newAttribute setObject:object forKey:EDValue];
    }
    else if ([columnIdentifier isEqualToString:@"visible"]) {
        [newAttribute setValue:EDGraphPointAttributeVisible forKey:EDKey];
        [newAttribute setObject:object forKey:EDValue];
    }
    else if ([columnIdentifier isEqualToString:@"label"]) {
        [newAttribute setValue:EDGraphPointAttributeShowLabel forKey:EDKey];
        [newAttribute setObject:object forKey:EDValue];
    }
    
    // set the attribute for the graph that holds this point
    // set the common points
    [[EDCoreDataUtility sharedCoreDataUtility] setAllCommonPointsforSelectedGraphs:newPoint attribute:newAttribute];
}

#pragma mark table delegate
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    // if nothing selected
    if ([pointsTable numberOfSelectedRows] == 0) {
        [buttonPointRemove setEnabled:FALSE];
    }
    else{
        [buttonPointRemove setEnabled:TRUE];
    }
}

- (void)onContextChanged:(NSNotification *)note{
    [pointsTable reloadData];
    //NSLog(@"context changed.");
}
@end
