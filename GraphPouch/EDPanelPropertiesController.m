//
//  EDPanelPropertiesController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/28/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesController.h"
#import "EDCoreDataUtility.h"
#import "EDConstants.h"
#import "EDPanelViewController.h"
#import "NSObject+Document.h"

@interface EDPanelPropertiesController ()
- (void)setCorrectView;
- (void)onContextChanged:(NSNotification *)note;
- (void)onShortcutPastePressed:(NSNotification *)note;
@end

@implementation EDPanelPropertiesController
- (id)init{
    self = [super initWithWindowNibName:@"EDPanelProperties"];
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        _nc = [NSNotificationCenter defaultCenter];
    }
    
    return self;
}

/*
- (void)close{
    NSLog(@"closing panel.");
    [super close];
}*/

- (void)dealloc{
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [_nc removeObserver:self name:EDEventShortcutPaste object:[self window]];
}

- (void)closePanel{
    [[self window] close];
}

- (void)windowDidLoad{
    // set menu state if opened
    if([[NSUserDefaults standardUserDefaults] boolForKey:EDPreferencePropertyPanel]){
        [menuItemProperties setState:NSOnState];
    }
    [super windowDidLoad];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window{
    // have the undo manager linked to the managed object context
    return [_context undoManager];
}

- (void)postInitialize:(NSManagedObjectContext *)context
{
    _context = context;
    
    //[super windowDidLoad];
    // init panel if needed
    if([[NSUserDefaults standardUserDefaults] boolForKey:EDPreferencePropertyPanel]){
        [self showWindow:self];
        [self setCorrectView];
    }
    
    [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [_nc addObserver:self selector:@selector(onShortcutPastePressed:) name:EDEventShortcutSave object:[self window]];
}

- (void)togglePropertiesPanel:(id)sender{
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    NSLog(@"toggling property panel:%@ is open?:%d", [self window], [self isWindowLoaded]);
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
    EDPanelViewController *viewController;
    
    // get all the selected objects
    NSMutableDictionary *selectedTypes = [EDCoreDataUtility getAllTypesOfSelectedWorksheetElements:_context];
    
#warning add other elements here, need to check for other entities
    if([selectedTypes valueForKey:EDEntityNameGraph]){
        if(!graphController){
            graphController = [[EDPanelPropertiesGraphController alloc] initWithNibName:@"EDPanelPropertiesGraph" bundle:nil];
        }
        viewController = graphController;
    }
    else {
        if(!documentController){
            documentController = [[EDPanelPropertiesDocumentController alloc] initWithNibName:@"EDPanelPropertiesDocument" bundle:nil];
        }
        viewController = documentController;
    }
    
#warning add other elements here, need to add other checks if we add other types
    // check to see if view is already being shown
    // if so then do nothing except update panel
    if ((viewController == graphController) && ([[self window] contentView] == [graphController view])) {
        // still need to update panel properties
        [viewController initWindowAfterLoaded:_context];
        return;
    }
    else if ((viewController == documentController) && ([[self window] contentView] == [documentController view])) {
        // still need to update panel properties
        [viewController initWindowAfterLoaded:_context];
        return;
    }
    
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
    
    // window init after loaded
    [viewController initWindowAfterLoaded:_context];
    
    // set content of the window
    [[self window] setContentView:[viewController view]];
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

- (BOOL)panelIsOpen{
    if(([self isWindowLoaded]) && ([[self window] isVisible])){
        return TRUE;
    }
    return FALSE;
}

#pragma mark context changed
- (void)onContextChanged:(NSNotification *)note{
    // set the correct view if window is showing
    if(([self isWindowLoaded]) && ([[self window] isVisible])){
        [self setCorrectView];
    }
}

#pragma mark keyboard
- (void)onShortcutPastePressed:(NSNotification *)note{
    [_nc postNotificationName:EDEventShortcutSave object:self];
}
@end
