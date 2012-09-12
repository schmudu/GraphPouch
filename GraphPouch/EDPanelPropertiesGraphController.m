//
//  EDPanelPropertiesGraphController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesGraphController.h"
#import "EDGraph.h"
#import "EDElement.h"
#import "EDConstants.h"

@interface EDPanelPropertiesGraphController ()
- (void)setElementLabelHeight;
- (void)setElementLabelWidth;
- (void)setElementLabelX;
- (void)setElementLabelY;
- (void)changeElementsAttributes:(float)newWidth height:(float)newHeight locationX:(float)newXPos locationY:(float)newYPos;
@end

@implementation EDPanelPropertiesGraphController

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
    [self setElementLabelHeight];
    [self setElementLabelWidth];
    [self setElementLabelX];
    [self setElementLabelY];
}

- (void)setElementLabelHeight{
    // this method will gather all of the selected objects and set the width label 
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    NSArray *graphs = [EDGraph findAllSelectedObjects];
    BOOL diff = FALSE;
    int i = 0;
    float height;
    EDElement *currentElement;
    
#warning add other elements here
    [elements addObjectsFromArray:graphs];
    while ((i < [elements count]) && (!diff)) {
        currentElement = [elements objectAtIndex:i];
        // if not the first and current height is not the same as previous height
        if((i != 0) && (height != [currentElement elementHeight])){
            diff = TRUE;
        }
        else {
            height = [currentElement elementHeight];
        }
        i++;
    }
    
    // if there is a diff then label shows nothing, otherwise show height
    if (diff) {
#warning need to figure out how to set custom color
        [labelHeight setStringValue:@""];
        [labelHeight setBackgroundColor:[NSColor grayColor]];
    }
    else {
        [labelHeight setStringValue:[NSString stringWithFormat:@"%.2f", height]];
        [labelHeight setBackgroundColor:[NSColor whiteColor]];
    }
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

- (void)setElementLabelY{
    // this method will gather all of the selected objects and set the width label 
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    NSArray *graphs = [EDGraph findAllSelectedObjects];
    BOOL diff = FALSE;
    int i = 0;
    float y;
    EDElement *currentElement;
    
#warning add other elements here
    [elements addObjectsFromArray:graphs];
    while ((i < [elements count]) && (!diff)) {
        currentElement = [elements objectAtIndex:i];
        // if not the first and current width is not the same as previous width
        if((i != 0) && (y != [currentElement locationY])){
            diff = TRUE;
        }
        else {
            y = [currentElement locationY];
        }
        i++;
    }
    
    // if there is a diff then label shows nothing, otherwise show width
    if (diff) {
#warning need to figure out how to set custom color
        [labelY setStringValue:@""];
        [labelY setBackgroundColor:[NSColor grayColor]];
    }
    else {
        [labelY setStringValue:[NSString stringWithFormat:@"%.2f", y]];
        [labelY setBackgroundColor:[NSColor whiteColor]];
    }
}

#pragma mark text field delegation
- (void)controlTextDidEndEditing:(NSNotification *)obj{
    [self changeElementsAttributes:[[labelWidth stringValue] floatValue] height:[[labelHeight stringValue] floatValue] locationX:[[labelX stringValue] floatValue] locationY:[[labelY stringValue] floatValue]];
}

#pragma mark elements
- (void)changeElementsAttributes:(float)newWidth height:(float)newHeight locationX:(float)newXPos locationY:(float)newYPos{
    NSMutableArray *elements = [_coreData getAllSelectedObjects];
    NSLog(@"going to change yPos to:%f element:%@", newYPos, elements);
    for (EDElement *element in elements){
        [element setValue:[[NSNumber alloc] initWithFloat:newWidth] forKey:EDElementAttributeWidth];
        [element setValue:[[NSNumber alloc] initWithFloat:newHeight] forKey:EDElementAttributeHeight];
        [element setValue:[[NSNumber alloc] initWithFloat:newXPos] forKey:EDElementAttributeLocationX];
        [element setValue:[[NSNumber alloc] initWithFloat:newYPos] forKey:EDElementAttributeLocationY];
    }
}

@end
