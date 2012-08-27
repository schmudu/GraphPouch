//
//  EDMenuViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/24/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDWorksheetView.h"
#import "EDWorksheetViewController.h"

@interface EDMenuViewController : NSObject <NSMenuDelegate>{
    IBOutlet NSMenuItem *snapToGrid;
    IBOutlet EDWorksheetViewController *worksheetViewController;
}

- (IBAction)toggleSnapToGrid:(id)sender;

@end
