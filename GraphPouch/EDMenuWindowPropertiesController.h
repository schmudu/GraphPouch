//
//  EDMenuWindowPropertiesController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/28/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDMenuWindowPropertiesController : NSWindowController <NSMenuDelegate>{
    IBOutlet NSMenuItem *menuItemProperties;
}

- (IBAction)toggleShowProperties:(id)sender;

@end
