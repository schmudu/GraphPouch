//
//  EDMenuWindowPropertiesController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/28/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuWindowPropertiesController.h"
#import "EDCoreDataUtility.h"
#import "EDConstants.h"


@interface EDMenuWindowPropertiesController ()
- (void)setCorrectView;
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
    NSViewController *viewController;
    if(([self isWindowLoaded]) && ([[self window] isVisible])){
        // close window
        [[self window] close];
        [menuItem setState:NSOffState];
    }
    else {
        [self showWindow:self];
        [menuItem setState:NSOnState];
        [self setCorrectView];
    }
}

- (void)setCorrectView{
    // based on what is selected, this method set the view controller
    
    // get all the selected objects
    EDCoreDataUtility *_coreData = [EDCoreDataUtility sharedCoreDataUtility];
    NSMutableDictionary *selectedTypes = [_coreData getAllTypesOfSelectedObjects];
    
    if([selectedTypes valueForKey:EDEntityNameGraph]){
        NSLog(@"there is something for graph.");
    }
    else {
        NSLog(@"there is nothing selected.");
    }
        
              
    
    // old code
    /*
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
     */
    
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
