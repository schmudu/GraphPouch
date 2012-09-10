//
//  EDMenuController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/9/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuController.h"
#import "EDMenuWindowPropertiesController.h"
#import "EDConstants.h"

@implementation EDMenuController

- (IBAction)togglePropertiesPanel:(id)sender{
    if(!propertiesController){
        propertiesController = [EDMenuWindowPropertiesController getInstance];
    }
    
    [propertiesController toggleShowProperties:sender];
}

// init any panels that need to be opened
- (void)postInitialize{
    if(!propertiesController){
        //propertiesController = [[EDMenuWindowPropertiesController alloc] init];
        NSLog(@"document post init.");
        propertiesController = [EDMenuWindowPropertiesController getInstance];
    }
    
    // show properties if needed
    if ([[NSUserDefaults standardUserDefaults] boolForKey:EDPreferencePropertyPanel]){
        [propertiesController showWindow:self];
        [propertiesController setCorrectView];
    }
}
@end
