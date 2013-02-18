//
//  EDPanelPropertiesDocumentController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesDocumentController.h"
#import "EDConstants.h"

@interface EDPanelPropertiesDocumentController ()

@end

@implementation EDPanelPropertiesDocumentController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)onButtonNamePressed:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPanelDocumentPressedName object:self];
}

- (IBAction)onButtonDatePressed:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPanelDocumentPressedDate object:self];
}

- (void)initWindowAfterLoaded{
    //NSLog(@"document view did load.");
}
@end
