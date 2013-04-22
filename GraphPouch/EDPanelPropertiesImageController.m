//
//  EDPanelPropertiesImageController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/22/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDImage.h"
#import "EDPanelPropertiesImageController.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDPanelPropertiesImageController ()

@end

@implementation EDPanelPropertiesImageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)onMatchDimensions:(id)sender{
    NSArray *images = [EDImage getAllSelectedObjects:_context];
    NSImage *tempImage;
    
    for (EDImage *image in images){
        // get the original size of the image
        tempImage = [[NSImage alloc] initWithData:[image imageData]];
        
        // set new size
        [image setElementWidth:tempImage.size.width];
        [image setElementHeight:tempImage.size.height];
    }
}



- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelX];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelY];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelWidth];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlReceivedFocus object:labelHeight];
}

- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context{
    _context = context;
    [self setElementLabel:labelX attribute:EDElementAttributeLocationX];
    [self setElementLabel:labelY attribute:EDElementAttributeLocationY];
    [self setElementLabel:labelWidth attribute:EDElementAttributeWidth];
    [self setElementLabel:labelHeight attribute:EDElementAttributeHeight];
}

- (void)viewDidLoad{
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelX];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelWidth];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onControlReceivedFocus:) name:EDEventControlReceivedFocus object:labelHeight];
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
    else if ([obj object] == labelHeight) {
        [self changeSelectedElementsAttribute:EDElementAttributeHeight newValue:[[NSNumber alloc] initWithFloat:[[labelHeight stringValue] floatValue]]];
    }
}

@end
