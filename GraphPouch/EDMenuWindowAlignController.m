//
//  EDMenuWindowAlignController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/27/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuWindowAlignController.h"

@interface EDMenuWindowAlignController ()

@end

@implementation EDMenuWindowAlignController

- (id)init{
    self = [super initWithWindowNibName:@"EDMenuWindowAlign"];
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

@end
