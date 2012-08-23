//
//  EDPreferenceControllerWindowController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDPreferencesController: NSWindowController{
    IBOutlet NSButton *snapToGuide;
}

- (IBAction)changeSnapToGuide:(id)sender;

@end
