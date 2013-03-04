//
//  EDWindowControllerAbout.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/3/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDWindowControllerAbout.h"

@interface EDWindowControllerAbout ()

@end

@implementation EDWindowControllerAbout

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

- (void)toggleAboutWindow:(id)sender{
    if(([self isWindowLoaded]) && ([[self window] isVisible])){
        // close window
        [[self window] close];
    }
    else {
        [self showWindow:self];
    }
}
@end
