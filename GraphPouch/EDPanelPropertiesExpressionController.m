//
//  EDPanelPropertiesExpressionController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/15/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDPanelPropertiesExpressionController.h"

@interface EDPanelPropertiesExpressionController ()

@end

@implementation EDPanelPropertiesExpressionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context{
    _context = context;
    [self setElementLabel:labelX attribute:EDElementAttributeLocationX];
    [self setElementLabel:labelY attribute:EDElementAttributeLocationY];
    [self setElementLabel:labelWidth attribute:EDElementAttributeWidth];
    [self setElementLabel:labelHeight attribute:EDElementAttributeHeight];
    [self setElementLabel:labelExpression withStringAttribute:EDExpressionAttributeExpression];
}


- (void)controlTextDidEndEditing:(NSNotification *)obj{
    if (!_fieldChanged)
        return;
    
    // only change the specific attribute that was changed
    if ([obj object] == labelX) {
        [self changeSelectedElementsAttribute:EDElementAttributeLocationX newValue:[[NSNumber alloc] initWithFloat:[[labelX stringValue] floatValue]]];
    }
    else if ([obj object] == labelY) {
        [self changeSelectedElementsAttribute:EDElementAttributeLocationY newValue:[[NSNumber alloc] initWithFloat:[[labelY stringValue] floatValue]]];
    }
    else if ([obj object] == labelWidth) {
        [self changeSelectedElementsAttribute:EDElementAttributeWidth newValue:[[NSNumber alloc] initWithFloat:[[labelWidth stringValue] floatValue]]];
    }
    else if ([obj object] == labelHeight) {
        [self changeSelectedElementsAttribute:EDElementAttributeHeight newValue:[[NSNumber alloc] initWithFloat:[[labelHeight stringValue] floatValue]]];
    }
    else if ([obj object] == labelExpression) {
        [self changeSelectedElementsAttribute:EDExpressionAttributeExpression newValue:[labelExpression stringValue]];
    }
}
@end
