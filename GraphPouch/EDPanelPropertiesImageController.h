//
//  EDPanelPropertiesImageController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/22/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPanelViewController.h"

@interface EDPanelPropertiesImageController : EDPanelViewController{
    IBOutlet NSTextField *labelX;
    IBOutlet NSTextField *labelY;
    IBOutlet NSTextField *labelWidth;
    IBOutlet NSTextField *labelHeight;
}

- (IBAction)onMatchDimensions:(id)sender;

@end
