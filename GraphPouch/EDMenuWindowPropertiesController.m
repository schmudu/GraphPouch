//
//  EDMenuWindowPropertiesController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/28/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuWindowPropertiesController.h"

@interface EDMenuWindowPropertiesController ()

@end

@implementation EDMenuWindowPropertiesController
- (id)init{
    self = [super initWithWindowNibName:@"EDMenuWindowProperties"];
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)toggleShowProperties:(id)sender{
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    if(([self isWindowLoaded]) && ([[self window] isVisible])){
        // close window
        [[self window] close];
        [menuItem setState:NSOffState];
    }
    else {
        [self showWindow:self];
        [menuItem setState:NSOnState];
    }
}

- (void)menuWillOpen:(NSMenu *)menu{
    // set state based on state of window
    if(([self isWindowLoaded]) && ([[self window] isVisible])){
        [menuItemProperties setState:NSOnState];
    }
    else {
        [menuItemProperties setState:NSOffState];
    }
}

@end
