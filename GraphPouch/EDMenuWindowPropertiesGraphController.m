//
//  EDMenuWindowPropertiesGraphController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuWindowPropertiesGraphController.h"
#import "EDGraph.h"
#import "EDElement.h"

@interface EDMenuWindowPropertiesGraphController ()
- (void)setElementLabelWidth;
@end

@implementation EDMenuWindowPropertiesGraphController

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
    [self setElementLabelWidth];
}

- (void)setElementLabelWidth{
    // this method will gather all of the selected objects and set the width label 
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    NSArray *graphs = [EDGraph findAllSelectedObjects];
    BOOL diff = FALSE;
    int i = 0;
    float width;
    EDElement *currentElement;
    
#warning add other elements here
    [elements addObjectsFromArray:graphs];
    while ((i < [elements count]) && (!diff)) {
        currentElement = [elements objectAtIndex:i];
        // if not the first and current width is not the same as previous width
        NSLog(@"width: %f", [currentElement elementWidth]);
        if((i != 0) && (width != [currentElement elementWidth])){
            diff = TRUE;
        }
        else {
            width = [currentElement elementWidth];
        }
        i++;
    }
    
    // if there is a diff then label shows nothing, otherwise show width
    if (diff) {
#warning need to figure out how to set custom color
        [labelWidth setBackgroundColor:[NSColor grayColor]];
    }
    else {
        [labelWidth setStringValue:[NSString stringWithFormat:@"%f", width]];
    }
}

@end
