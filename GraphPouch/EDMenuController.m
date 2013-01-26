//
//  EDMenuController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/9/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuController.h"
#import "EDPanelPropertiesController.h"
#import "EDConstants.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDPage.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDMenuController()
- (void)onContextChanged:(NSNotification *)note;
//- (NSMenuItem *)pageNext;
//- (NSMenuItem *)pagePrevious;
@end

@implementation EDMenuController

- (id)initWithContext:(NSManagedObjectContext *)context{
    self = [super init];
    if(self){
        _context = context;
        NSLog(@"init menu controller: context:%@", _context);
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    return self;
}

- (void)onContextChanged:(NSNotification *)note{
    /*
    //disable/enable menu items based on what's selected
    NSArray *pages = [EDPage getAllObjects:_context];
    NSMenuItem *pageNext, *pagePrevious;
    pageNext = [self pageNext];
    pagePrevious = [self pagePrevious];
    
    if ([pages count] <= 1) {
        // disable page menu items
        [pageNext setEnabled:FALSE];
        [pagePrevious setEnabled:FALSE];
    }
    else{
        // disable page menu items
        [pageNext setEnabled:TRUE];
        [pagePrevious setEnabled:TRUE];
    }
     */
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

#pragma mark menu items
/*
 - (NSMenuItem *)pagePrevious{
    return [[[[NSApp menu] itemWithTitle:@"Edit"] submenu] itemWithTitle:@"Previous Page"];
}

- (NSMenuItem *)pageNext{
    return [[[[NSApp menu] itemWithTitle:@"Edit"] submenu] itemWithTitle:@"Next Page"];
}

- (IBAction)togglePropertiesPanel:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] togglePropertiesPanel:sender];
}

- (IBAction)addGraph:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] addGraph:sender];
}

- (IBAction)addPage:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] addPage:sender];
}
- (IBAction)selectAll:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] selectAll:sender];
}

- (IBAction)deselectAll:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] deselectAll:sender];
}

- (IBAction)nextPage:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] nextPage:sender];
}

- (IBAction)previousPage:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] previousPage:sender];
}

- (IBAction)nextWorksheetItem:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] nextWorksheetItem:sender];
}

- (IBAction)previousWorksheetItem:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] previousWorksheetItem:sender];
}*/

@end
