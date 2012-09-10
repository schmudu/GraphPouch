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
#import "EDMenuWindowController.h"

@interface EDMenuWindowPropertiesController ()
- (void)setCorrectView;
- (void)onContextChanged:(NSNotification *)note;
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
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        _context = [_coreData context];
        _nc = [NSNotificationCenter defaultCenter];
               
        [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    
    return self;
}

- (void)dealloc{
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

- (void)windowDidLoad{
    NSLog(@"window did open.");
    // set menu state if opened
    if([[NSUserDefaults standardUserDefaults] boolForKey:EDPreferencePropertyPanel]){
        NSLog(@"setting state to true: menu:%@", menuItemProperties);
        [menuItemProperties setState:NSOnState];
    }
    [super windowDidLoad];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    NSLog(@"awake from nib: menu:%@", menuItemProperties);
}

- (void)postInitialize
{
    //[super windowDidLoad];
    // init panel if needed
    NSLog(@"post initialize.");
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:EDPreferencePropertyPanel]){
        [self showWindow:self];
        [self setCorrectView];
    }
}

- (void)togglePropertiesPanel:(id)sender{
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    if(([self isWindowLoaded]) && ([[self window] isVisible])){
        // close window
        [[self window] close];
        [menuItem setState:NSOffState];
        
        // set preferences
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:EDPreferencePropertyPanel];
    }
    else {
        [self showWindow:self];
        [menuItem setState:NSOnState];
        [self setCorrectView];
        
        // set preferences
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:EDPreferencePropertyPanel];
    }
}

- (void)setCorrectView{
    // based on what is selected, this method set the view controller
    EDMenuWindowController *viewController;
    
    // get all the selected objects
    NSMutableDictionary *selectedTypes = [_coreData getAllTypesOfSelectedObjects];
    
#warning add other elements here, need to check for other entities
    if([selectedTypes valueForKey:EDEntityNameGraph]){
        if(!graphController){
            graphController = [[EDMenuWindowPropertiesGraphController alloc] initWithNibName:@"EDMenuWindowPropertiesGraph" bundle:nil];
        }
        viewController = graphController;
    }
    else {
        if(!documentController){
            documentController = [[EDMenuWindowPropertiesDocumentController alloc] initWithNibName:@"EDMenuWindowPropertiesDocument" bundle:nil];
        }
        viewController = documentController;
    }
    
#warning need to clean this up
    //Compute the new window frame
    NSSize currentSize = [[[self window] contentView] frame].size;
    NSSize newSize = [[viewController view] frame].size;
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
    [[self window] setContentView:[viewController view]];
    
    // window init after loaded
    [viewController initWindowAfterLoaded];
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

#pragma mark context changed

- (void)onContextChanged:(NSNotification *)note{
    // set the correct view if window is showing
    if(([self isWindowLoaded]) && ([[self window] isVisible])){
        [self setCorrectView];
    }
}

@end
