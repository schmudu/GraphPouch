//
//  EDPanelPropertiesLineController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelViewController.h"

@interface EDPanelPropertiesLineController : EDPanelViewController{
    IBOutlet NSTextField *labelX;
    IBOutlet NSTextField *labelY;
    IBOutlet NSTextField *labelWidth;
    IBOutlet NSTextField *labelThickness;
}
@end
