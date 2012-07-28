//
//  EDPropertiesController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/27/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPropertiesController.h"
#import "EDPropertiesViewControllerGraph.h"

@interface EDPropertiesController ()

@end

@implementation EDPropertiesController

- (id)init{
    // self = [super init];
    self = [self initWithWindowNibName:@"EDPropertiesView"];
    
    if (self) {
        //NSLog(@"regular init being called.");
    }
    return self;
    
}
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        //NSLog(@"initializing properties window.");
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSLog(@"window just loaded.");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)showPropertiesPanel:(id)sender{
    if(!viewControllerGraph){
        viewControllerGraph = [[EDPropertiesViewControllerGraph alloc] initWithNibName:@"EDPropertiesViewGraph" bundle:nil];
    }
    // show my window
    [self showWindow:self];
    
    #warning need to clean this up
    // DUPLICATED CODE - see showPropertiesPanelText
    //Compute the new window frame
    NSSize currentSize = [[[self window] contentView] frame].size;
    NSSize newSize = [[viewControllerGraph view] frame].size;
    float deltaWidth = newSize.width - currentSize.width;
    float deltaHeight = newSize.height - currentSize.height;
    NSRect windowFrame = [[self window] frame];
    windowFrame.size.height += deltaHeight;
    windowFrame.origin.y -= deltaHeight;
    windowFrame.size.width += deltaWidth;
    
    // Clear box for resizing
    [[self window] setContentView:nil];
    [[self window] setFrame:windowFrame display:TRUE animate:TRUE];
    // END DUPLICATE
    
    // set content of the window
    [[self window] setContentView:[viewControllerGraph view]];
}


- (IBAction)showPropertiesPanelText:(id)sender{
    if(!viewControllerText){
        viewControllerText = [[EDPropertiesViewControllerText alloc] initWithNibName:@"EDPropertiesViewText" bundle:nil];
    }
    
    // show my window
    [self showWindow:self];
    
    //Compute the new window frame
    NSSize currentSize = [[[self window] contentView] frame].size;
    NSSize newSize = [[viewControllerText view] frame].size;
    float deltaWidth = newSize.width - currentSize.width;
    float deltaHeight = newSize.height - currentSize.height;
    NSRect windowFrame = [[self window] frame];
    windowFrame.size.height += deltaHeight;
    windowFrame.origin.y -= deltaHeight;
    windowFrame.size.width += deltaWidth;
    
    // Clear box for resizing
    [[self window] setContentView:nil];
    [[self window] setFrame:windowFrame display:TRUE animate:TRUE];
    
    // set content of the window
    [[self window] setContentView:[viewControllerText view]];
}

@end
