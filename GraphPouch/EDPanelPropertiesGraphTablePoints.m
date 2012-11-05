//
//  EDPanelPropertiesGraphTablePoints.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesGraphTablePoints.h"
#import "EDCoreDataUtility.h"

@implementation EDPanelPropertiesGraphTablePoints

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    NSDictionary *commonPointsForSelectedGraphs = [[EDCoreDataUtility sharedCoreDataUtility] getAllCommonPointsforSelectedGraphs];
    NSLog(@"return count of:%ld", [commonPointsForSelectedGraphs count]);
    return [commonPointsForSelectedGraphs count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    // the return value is typed as (id) because it will return a string in all cases with the exception of the
    id returnValue=nil;
    
    // The column identifier string is the easiest way to identify a table column. Much easier
    // than keeping a reference to the table column object.
    NSString *columnIdentifer = [tableColumn identifier];
    
    // Get the name at the specified row in the namesArray
    //NSString *theName = [namesArray objectAtIndex:rowIndex];
    
    
    // Compare each column identifier and set the return value to
    // the Person field value appropriate for the column.
    /*
    if ([columnIdentifer isEqualToString:@"name"]) {
        returnValue = theName;
    }*/
    
    
    //return returnValue; 
    return @"Patrick";
}

@end
