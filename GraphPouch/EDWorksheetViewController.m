//
//  EDWorksheetControllerViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDWorksheetViewController.h"
#import "EDWorksheetView.h"
#import "EDConstants.h"
//#import "EDCoreDataUtility.h"

@interface EDWorksheetViewController ()
- (void)deselectAllElements:(NSNotification *)note;
- (void)deleteSelectedElements:(NSNotification *)note;
@end

@implementation EDWorksheetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _nc = [NSNotificationCenter defaultCenter];
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        
        // listen
        //NSLog(@"init worksheet view controller.");
    }
    
    return self;
}

- (void)postInitialize{
    // listeners
    [_nc addObserver:self selector:@selector(deselectAllElements:) name:EDEventWorksheetClicked object:[self view]];
    [_nc addObserver:self selector:@selector(deselectAllElements:) name:EDEventUnselectedGraphClickedWithoutModifier object:[self view]];
    [_nc addObserver:self selector:@selector(deleteSelectedElements:) name:EDEventDeleteKeyPressedWithoutModifiers object:[self view]];
    [_nc addObserver:self selector:@selector(alignElementsToTop:) name:EDEventMenuAlignTop object:nil];
    
    // initialize view to display all of the objects
    [(EDWorksheetView *)[self view] drawLoadedObjects];
}

- (void)deselectAllElements:(NSNotification *)note{
    // clear all the selected elements
    [[EDCoreDataUtility sharedCoreDataUtility] clearSelectedElements];
}

- (void)dealloc{
    [_nc removeObserver:self name:EDEventWorksheetClicked object:[self view]];
    [_nc removeObserver:self name:EDEventUnselectedGraphClickedWithoutModifier object:[self view]];
    [_nc removeObserver:self name:EDEventDeleteKeyPressedWithoutModifiers object:[self view]];
    [_nc removeObserver:self name:EDEventMenuAlignTop object:nil];
}

- (void)deleteSelectedElements:(NSNotification *)note{
    [_coreData deleteSelectedElements];
}

#pragma mark graphs
- (void)addNewGraph{
    /*
    // create new page
    NSArray *pages = [_coreData getAllPages];
    EDPage *newPage = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[_coreData context]] insertIntoManagedObjectContext:[_coreData context]];
    
    // if no other pages then set this page to be the first one
    if ([pages count] == 0) {
        [newPage setPageNumber:[[NSNumber alloc] initWithInt:1]];
    }
    else {
        EDPage *lastPage = [_coreData getLastSelectedPage];
        if (lastPage) {
            NSArray *pagesNeedUpdating = [_coreData getAllPagesWithPageNumberGreaterThan:[[lastPage pageNumber] intValue]];
            
            //update page numbers 
            for (EDPage *page in pagesNeedUpdating){
                [page setPageNumber:[[NSNumber alloc] initWithInt:([[page pageNumber] intValue] + 1)]];
            }
            
            [newPage setPageNumber:[[NSNumber alloc] initWithInt:([[lastPage pageNumber] intValue]+1)]];
        }
        else {
            // nothing is selected so add page to the end of the list
            [newPage setPageNumber:[[NSNumber alloc] initWithInt:([pages count] + 1)]];
        }
    }
     */
    NSLog(@"creating new graph.");
}


#pragma mark align
- (void)alignElementsToTop:(NSNotification *)note{
    NSLog(@"need to align elements to the top.");
}

@end
