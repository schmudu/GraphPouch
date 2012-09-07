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
#import "EDConstants.h"

@interface EDMenuWindowPropertiesGraphController ()
- (void)setElementLabelWidth;
- (void)setElementLabelX;
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
    [self setElementLabelX];
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
        [labelWidth setStringValue:@""];
        [labelWidth setBackgroundColor:[NSColor grayColor]];
    }
    else {
        [labelWidth setStringValue:[NSString stringWithFormat:@"%.2f", width]];
        [labelWidth setBackgroundColor:[NSColor whiteColor]];
    }
}

- (void)setElementLabelX{
    // this method will gather all of the selected objects and set the width label 
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    NSArray *graphs = [EDGraph findAllSelectedObjects];
    BOOL diff = FALSE;
    int i = 0;
    float x;
    EDElement *currentElement;
    
#warning add other elements here
    [elements addObjectsFromArray:graphs];
    while ((i < [elements count]) && (!diff)) {
        currentElement = [elements objectAtIndex:i];
        // if not the first and current width is not the same as previous width
        if((i != 0) && (x != [currentElement locationX])){
            diff = TRUE;
        }
        else {
            x = [currentElement locationX];
        }
        i++;
    }
    
    // if there is a diff then label shows nothing, otherwise show width
    if (diff) {
#warning need to figure out how to set custom color
        [labelX setStringValue:@""];
        [labelX setBackgroundColor:[NSColor grayColor]];
    }
    else {
        [labelX setStringValue:[NSString stringWithFormat:@"%.2f", x]];
        [labelX setBackgroundColor:[NSColor whiteColor]];
    }
}

#pragma mark text field delegation
- (void)controlTextDidEndEditing:(NSNotification *)obj{
#warning need to validate input
#warning can abstract-ize this method
    [self changeElementsWidth:[[labelWidth stringValue] floatValue]];
}

#pragma mark elements
- (void)changeElementsWidth:(float)newWidth{
    NSMutableArray *elements = [_coreData getAllSelectedObjects];
    for (EDElement *element in elements){
        [element setValue:[[NSNumber alloc] initWithFloat:newWidth] forKey:EDElementAttributeWidth];
    }
}

@end
