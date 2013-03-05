//
//  EDPanelPropertiesGraphLineController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesGraphLineController.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"

@interface EDPanelPropertiesGraphLineController ()

@end

@implementation EDPanelPropertiesGraphLineController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelX];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelY];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelWidth];
}

- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context{
    _context = context;
    [self setElementLabel:labelX attribute:EDElementAttributeLocationX];
    [self setElementLabel:labelY attribute:EDElementAttributeLocationY];
    [self setElementLabel:labelWidth attribute:EDElementAttributeWidth];
}

- (void)viewDidLoad{
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelWidth];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj{
    // if field did not change then do nothing
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
}
@end
