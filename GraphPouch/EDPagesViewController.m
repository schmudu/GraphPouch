//
//  EDPagesViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPagesViewController.h"
#import "EDPage.h"
#import "EDPageView.h"
#import "EDPagesView.h"
#import "EDConstants.h"
#import "EDPageViewController.h"

@interface EDPagesViewController ()
- (void)onContextChanged:(NSNotification *)note;
- (void)drawPage:(EDPage *)page;
- (void)removePage:(EDPage *)page;
- (void)correctPagePositionsAfterUpdate;
- (void)correctPagePositionsAfterUpdateWithoutAnimation;
- (void)deselectAllPages;
- (void)onPageViewClickedWithoutModifier:(NSNotification *)note;
- (void)onPageViewStartDrag:(NSNotification *)note;
- (void)onPagesViewClicked:(NSNotification *)note;
- (void)onDeleteKeyPressed:(NSNotification *)note;
- (void)onWindowResized:(NSNotification *)note;
@end

@implementation EDPagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pageControllers = [[NSMutableArray alloc] init];
        _nc = [NSNotificationCenter defaultCenter];
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        
        // listen
        [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:[_coreData context]];
    }
    
    return self;
}

- (void)dealloc{
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[_coreData context]];
    [_nc removeObserver:self name:EDEventPagesDeletePressed object:[self view]];
    [_nc removeObserver:self name:EDEventPagesViewClicked object:[self view]];
    [_nc removeObserver:self name:EDEventWindowDidResize object:_documentController];
}

- (void)postInitialize{
    NSArray *pages = [_coreData getAllPages];
    
    // if no pages then we need to create one
    if([pages count] == 0){
        [self addNewPage];
    }
    else{
        // else draw the pages that already exist
        for(EDPage *page in pages){
            [self drawPage:page];
        }
    }
    
    // init view
    [(EDPagesView *)[self view] postInitialize];
    
    // listen
    [_nc addObserver:self selector:@selector(onPagesViewClicked:) name:EDEventPagesViewClicked object:[self view]];
    [_nc addObserver:self selector:@selector(onDeleteKeyPressed:) name:EDEventPagesDeletePressed object:[self view]];
    [_nc addObserver:self selector:@selector(onWindowResized:) name:EDEventWindowDidResize object:_documentController];
}


- (void)addNewPage{
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
            [newPage setPageNumber:[[NSNumber alloc] initWithInt:[[lastPage pageNumber] intValue]]];
        }
        else {
            // nothing is selected so add page to the end of the list
            [newPage setPageNumber:[[NSNumber alloc] initWithInt:([pages count] + 1)]];
        }
    }
}

- (void)onContextChanged:(NSNotification *)note{
    NSArray *insertedArray = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    int entityDeleted = FALSE;
    
    for (NSObject *addedObject in insertedArray){
        if ([[addedObject className] isEqualToString:EDEntityNamePage]) {
            [self drawPage:(EDPage *)addedObject];
        }
    }
    
    NSArray *deletedArray = [[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects];
    for (NSObject *removedObject in deletedArray){
        // only remove page objects
        if ([[removedObject className] isEqualToString:EDEntityNamePage]) {
            entityDeleted = TRUE;
            [self removePage:(EDPage *)removedObject];
        }
    }

    // correct array if objects deleted
    if (entityDeleted) {
        [_coreData correctPageNumbersAfterDelete];
        
        // for some reason we need to save, context does not update right away
        [_coreData save];
    }
    
    // update positions of pages
    [self correctPagePositionsAfterUpdate];
}

- (void)drawPage:(EDPage *)page{
    EDPageViewController *pageController = [[EDPageViewController alloc] initWithPage:page];
 
    // add controller to array so we can iterate through them
    [_pageControllers addObject:pageController];
    
    // add to view
    [[self view] addSubview:[pageController view]];
    
    //position it
    [[pageController view] setFrameOrigin:NSMakePoint(EDPageViewPosX, ([[page pageNumber] intValue]-1)*EDPageViewIncrementPosY + EDPageViewOffsetY)];
    
    // init view after loaded
    [pageController postInit];
    
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewClickedWithoutModifier:) name:EDEventPageClickedWithoutModifier object:pageController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewStartDrag:) name:EDEventPageViewStartDrag object:pageController];
}

- (void)removePage:(EDPage *)page{
    // iterate through page controllers and remove controller and page
    int i = 0;
    EDPageViewController *currentPageController;
    
    while (i < [_pageControllers count]) {
        currentPageController = (EDPageViewController *)[_pageControllers objectAtIndex:i];
        
        if ([(EDPageView *)[currentPageController view] dataObj] == page){
            // remove listener
            [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPageClickedWithoutModifier object:currentPageController];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPageViewStartDrag object:currentPageController];
            
            // remove page view
            [[currentPageController view] removeFromSuperview];
            
            // remove controller
            [_pageControllers removeObject:currentPageController];
            
            return;
        }
        i++;
    }
}

#pragma mark page events
- (void)onPageViewStartDrag:(NSNotification *)note{
    [(EDPagesView *)[self view] setPageViewStartDragInfo:[[note userInfo] objectForKey:EDKeyPageViewData]];
}

- (void)onPageViewClickedWithoutModifier:(NSNotification *)note{
    [self deselectAllPages];
}

- (void)onPagesViewClicked:(NSNotification *)note{
    [self deselectAllPages];
}

- (void)deselectAllPages{
     // iterate through page controllers and deselect   
    for (EDPageViewController *pageController in _pageControllers){
        [pageController deselectPage];
    }
}

#pragma mark pages events
- (void)onDeleteKeyPressed:(NSNotification *)note{
    [_coreData deleteSelectedPages];
}

- (void)correctPagePositionsAfterUpdate{
    // move pages to correct position based on page label
    for (EDPageViewController *pageController in _pageControllers){
        [[[pageController view] animator] setFrameOrigin:NSMakePoint(EDPageViewPosX, ([[[pageController dataObj] pageNumber] intValue]-1)*EDPageViewIncrementPosY + EDPageViewOffsetY)];
    }
}

- (void)correctPagePositionsAfterUpdateWithoutAnimation{
    // move pages to correct position based on page label without animation
    for (EDPageViewController *pageController in _pageControllers){
        [[pageController view] setFrameOrigin:NSMakePoint(EDPageViewPosX, ([[[pageController dataObj] pageNumber] intValue]-1)*EDPageViewIncrementPosY + EDPageViewOffsetY)];
    }
}

#pragma mark window
- (void)onWindowResized:(NSNotification *)note{
    // need to redraw positions
    [self correctPagePositionsAfterUpdateWithoutAnimation];
}
@end
