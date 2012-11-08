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
#import "EDConstants.h"

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
    NSArray *commonPoints = [[EDCoreDataUtility sharedCoreDataUtility] getAllCommonPointsforSelectedGraphs];
    // sort
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationX" ascending:TRUE];
    NSArray *descriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSArray *sortedArray = [commonPoints sortedArrayUsingDescriptors:descriptorArray];
    
    // return value based on column identifier
    if ([columnIdentifier isEqualToString:@"x"]) {
        returnValue = [[NSNumber alloc] initWithFloat:[(EDPoint *)[sortedArray objectAtIndex:row] locationX]];
    }
    else if ([columnIdentifier isEqualToString:@"y"]) {
        returnValue = [[NSNumber alloc] initWithFloat:[(EDPoint *)[sortedArray objectAtIndex:row] locationY]];
    }
    else if ([columnIdentifier isEqualToString:@"visible"]) {
        returnValue = [[NSNumber alloc] initWithBool:[(EDPoint *)[sortedArray objectAtIndex:row] isVisible]];
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
#warning change:EDPoint
    [newPoint setLocationX:[currentPoint locationX]];
    [newPoint setLocationY:[currentPoint locationY]];
    [newPoint setIsVisible:[currentPoint isVisible]];
    
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
    /*
    if ([columnIdentifier isEqualToString:@"x"]) {
        [(EDPoint *)[commonPoints objectAtIndex:row] setLocationX:[object floatValue]];
    }
    else if ([columnIdentifier isEqualToString:@"y"]) {
        [(EDPoint *)[commonPoints objectAtIndex:row] setLocationX:[object floatValue]];
    }
    else if ([columnIdentifier isEqualToString:@"visible"]) {
        [(EDPoint *)[commonPoints objectAtIndex:row] setIsVisible:[object boolValue]];
    }*/
    NSLog(@"going to change edpoint that matches:%@", newPoint);
    
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
