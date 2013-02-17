//
//  EDPanelPropertiesController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/28/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDCoreDataUtility.h"
#import "EDCoreDataUtility+Worksheet.h"
#import "EDPanelPropertiesController.h"
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
        _currentTextView = nil;
    }
    
    return self;
}

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
    // get all the selected objects
    NSMutableDictionary *selectedTypes = [EDCoreDataUtility getAllTypesOfSelectedWorksheetElements:_context];
    
#warning worksheet elements
    if([selectedTypes valueForKey:EDKeyGraph]){
        if(!graphController){
            graphController = [[EDPanelPropertiesGraphController alloc] initWithNibName:@"EDPanelPropertiesGraph" bundle:nil];
        }
        // set window title
        [[self window] setTitle:@"Graph Properties"];
            
        _viewController = graphController;
    }
    else if([selectedTypes valueForKey:EDKeyGraphLine]){
        if(!graphLineController){
            graphLineController = [[EDPanelPropertiesGraphLineController alloc] initWithNibName:@"EDPanelPropertiesGraphLine" bundle:nil];
        }
        // set window title
        [[self window] setTitle:@"Properties"];
            
        _viewController = graphLineController;
    }
    else if([selectedTypes valueForKey:EDKeyGraphTextbox]){
        if(!graphTextboxController){
            graphTextboxController = [[EDPanelPropertiesGraphTextboxController alloc] initWithNibName:@"EDPanelPropertiesGraphTextbox" bundle:nil];
        }
        // set window title
        [[self window] setTitle:@"Properties"];
            
        _viewController = graphTextboxController;
    }
    else if([selectedTypes valueForKey:EDKeyGraphLineTextbox]){
        if(!graphLineTextboxController){
            graphLineTextboxController = [[EDPanelPropertiesGraphLineTextboxController alloc] initWithNibName:@"EDPanelPropertiesGraphLineTextbox" bundle:nil];
        }
        // set window title
        [[self window] setTitle:@"Properties"];
            
        _viewController = graphLineTextboxController;
    }
    else if([selectedTypes valueForKey:EDKeyLine]){
        if(!lineController){
            lineController = [[EDPanelPropertiesLineController alloc] initWithNibName:@"EDPanelPropertiesLine" bundle:nil];
        }
        // set window title
        [[self window] setTitle:@"Line Properties"];
            
        _viewController = lineController;
    }
    else if([selectedTypes valueForKey:EDKeyLineTextbox]){
        if(!lineTextboxController){
            lineTextboxController = [[EDPanelPropertiesLineTextboxController alloc] initWithNibName:@"EDPanelPropertiesLineTextbox" bundle:nil];
        }
        // set window title
        [[self window] setTitle:@"Properties"];
            
        _viewController = lineTextboxController;
    }
    else if([selectedTypes valueForKey:EDKeyTextbox]){
        if(!textboxController){
            textboxController = [[EDPanelPropertiesTextboxController alloc] initWithNibName:@"EDPanelPropertiesTextbox" bundle:nil];
        }
        // set window title
        [[self window] setTitle:@"Textbox Properties"];
            
        _viewController = textboxController;
    }
    else if(_currentTextView){
        // set controller to text view
        if(!textViewController){
            textViewController = [[EDPanelPropertiesTextViewController alloc] initWithNibName:@"EDPanelPropertiesTextView" bundle:nil];
        }
        // set window title
        [[self window] setTitle:@"Text Properties"];
            
        _viewController = textViewController;
    }
    else {
        if(!documentController){
            documentController = [[EDPanelPropertiesDocumentController alloc] initWithNibName:@"EDPanelPropertiesDocument" bundle:nil];
        }
        // set window title
        [[self window] setTitle:@"Properties"];
            
        _viewController = documentController;
    }
    
#warning worksheet elements
    // check to see if view is already being shown
    // if so then do nothing except update panel
    if ((_viewController == graphController) && ([[self window] contentView] == [graphController view])) {
        // still need to update panel properties
        [_viewController initWindowAfterLoaded:_context];
        return;
    }
    else if ((_viewController == graphLineController) && ([[self window] contentView] == [graphLineController view])) {
        // still need to update panel properties
        [_viewController initWindowAfterLoaded:_context];
        return;
    }
    else if ((_viewController == graphTextboxController) && ([[self window] contentView] == [graphTextboxController view])) {
        // still need to update panel properties
        [_viewController initWindowAfterLoaded:_context];
        return;
    }
    else if ((_viewController == graphLineTextboxController) && ([[self window] contentView] == [graphLineTextboxController view])) {
        // still need to update panel properties
        [_viewController initWindowAfterLoaded:_context];
        return;
    }
    else if ((_viewController == lineController) && ([[self window] contentView] == [lineController view])) {
        // still need to update panel properties
        [_viewController initWindowAfterLoaded:_context];
        return;
    }
    else if ((_viewController == lineTextboxController) && ([[self window] contentView] == [lineTextboxController view])) {
        // still need to update panel properties
        [_viewController initWindowAfterLoaded:_context];
        return;
    }
    else if ((_viewController == textboxController) && ([[self window] contentView] == [textboxController view])) {
        // still need to update panel properties
        [_viewController initWindowAfterLoaded:_context];
        return;
    }
    else if ((_viewController == textViewController) && ([[self window] contentView] == [textViewController view])) {
        // still need to update panel properties
        //[_viewController initWindowAfterLoaded:_context];
        return;
    }
    else if ((_viewController == documentController) && ([[self window] contentView] == [documentController view])) {
        // still need to update panel properties
        [_viewController initWindowAfterLoaded:_context];
        return;
    }
    
    //Compute the new window frame
    NSSize currentSize = [[[self window] contentView] frame].size;
    NSSize newSize = [[_viewController view] frame].size;
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
    [_viewController initWindowAfterLoaded:_context];
    
    // set content of the window
    [[self window] setContentView:[_viewController view]];
    
    // if EDTextView is the controller then call special method
    if ([_viewController isKindOfClass:[EDPanelPropertiesTextViewController class]]){
        [(EDPanelPropertiesTextViewController *)_viewController initButtons:_currentTextView textbox:_currentTextbox];
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

#pragma textbox
- (void)onTextboxDidBeginEditing:(EDTextView *)currentTextView currentTextbox:(EDTextbox *)currentTextbox{
    _currentTextView = currentTextView;
    _currentTextbox = currentTextbox;
    
    if(([self isWindowLoaded]) && ([[self window] isVisible])){
        [self setCorrectView];
    }
}

- (void)onTextboxDidEndEditing{
    _currentTextView = nil;
    
    // update view
    if(([self isWindowLoaded]) && ([[self window] isVisible])){
        [self setCorrectView];
    }
}

- (void)onTextboxDidChange{
    if ([_viewController isKindOfClass:[EDPanelPropertiesTextViewController class]]){
        [(EDPanelPropertiesTextViewController *)_viewController updateButtonStates];
    }
}
@end
