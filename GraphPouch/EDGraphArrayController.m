//
//  EDGraphArrayController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraphArrayController.h"
#import "EDConstants.h"

@implementation EDGraphArrayController

- (id)newObject{
    id newObj = [super newObject];
    
    // default values
    [newObj setValue:[[NSString alloc] initWithString:@"default_equation123"] forKey:EDWorksheetAttributeEquation];
    [newObj setValue:[[NSNumber alloc] initWithBool:GRAPH_INIT_TICK_MARKS] forKey:EDWorksheetAttributeTickMarks];
    [newObj setValue:[[NSNumber alloc] initWithBool:GRAPH_INIT_HAS_GRID_LINES] forKey:EDWorksheetAttributeGridLines];
    [newObj setValue:[[NSNumber alloc] initWithFloat:0] forKey:EDWorksheetAttributeLocationX];
    [newObj setValue:[[NSNumber alloc] initWithFloat:0] forKey:EDWorksheetAttributeLocationY];
    [newObj setValue:[[NSNumber alloc] initWithBool:FALSE] forKey:EDWorksheetAttributeSelected];
    //NSLog(@"set value for selected:%@ obj:%@", [newObj valueForKey:EDWorksheetAttributeSelected], newObj);
    return newObj;
}

@end
