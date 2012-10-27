//
//  EDPagesViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDGraph.h"
#import "EDPagesViewController.h"
#import "EDPage.h"
#import "EDPageView.h"
#import "EDPagesView.h"
#import "EDConstants.h"
#import "EDPageViewController.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDPagesViewController ()
- (void)onContextChanged:(NSNotification *)note;
- (void)insertPageViews:(NSMutableArray *)pageViews toPage:(int)pageNumber;
- (void)removePageViews:(NSMutableArray *)pageViews;
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
- (void)onPagesViewFinishedDragged:(NSNotification *)note;
- (void)updateViewFrameSize;
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
    [_nc removeObserver:self name:EDEventPageViewsFinishedDrag object:[self view]];
    [_nc removeObserver:self name:EDEventWindowDidResize object:_documentController];
}

- (void)postInitialize{
    NSArray *pages = [_coreData getAllPages];
 
    // disable autoresize
    [[self view] setAutoresizesSubviews:FALSE];
    
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
    [_nc addObserver:self selector:@selector(onPagesViewFinishedDragged:) name:EDEventPageViewsFinishedDrag object:[self view]];
    [_nc addObserver:self selector:@selector(onWindowResized:) name:EDEventWindowDidResize object:_documentController];
}

#pragma mark page CRUD
- (void)insertPageViews:(NSMutableArray *)pageViews toPage:(int)pageNumber{
    EDPage *newPage;
    int currentPageNumber = pageNumber;
    
    // insert new pages
    for (EDPageView *pageView in pageViews){
        //NSLog(@"data in insert:%@", [pageView dataObj]);
        // create new page
        //newPage = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[_coreData context]] insertIntoManagedObjectContext:[_coreData context]];
        newPage = [pageView dataObj];
        //NSLog(@"inserting new page: to page number:%d", currentPageNumber);
        // set page number
        [newPage setPageNumber:[[NSNumber alloc] initWithInt:currentPageNumber]];
        
#warning need to figure out this after we set up core data relationships 
        currentPageNumber++;
    }
}
    
- (void)removePageViews:(NSMutableArray *)pageViews{
    for (EDPageView *pageView in pageViews){
        [_coreData removePage:[pageView dataObj]];
    }
}

- (void)addNewPage{
    // create new page
    NSArray *pages = [_coreData getAllPages];
    EDPage *newPage = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[_coreData context]] insertIntoManagedObjectContext:[_coreData context]];
    NSLog(@"adding new page: %@", newPage);
    //[newPage setGraphs:[[NSSet alloc] init]];
    
    // if no other pages then set this page to be the first one
    if ([pages count] == 0) {
        [newPage setPageNumber:[[NSNumber alloc] initWithInt:1]];
    }
    else {
        EDPage *lastPage = [_coreData getLastSelectedPage];
        if (lastPage) {
            NSArray *pagesNeedUpdating = [_coreData getPagesWithPageNumberGreaterThan:[[lastPage pageNumber] intValue]];
            
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
    //NSLog(@"created page:%@", newPage);
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

    // update positions of pages
    [self correctPagePositionsAfterUpdate];
    
    // update frame size
    [self updateViewFrameSize];
}

- (void)drawPage:(EDPage *)page{
    EDPageViewController *pageController = [[EDPageViewController alloc] initWithPage:page];
 
    // add controller to array so we can iterate through them
    [_pageControllers addObject:pageController];
    
    // add to view
    [[self view] addSubview:[pageController view]];
    
    //position one page below
    [[pageController view] setFrameOrigin:NSMakePoint(EDPageViewPosX, ([[page pageNumber] intValue]-2)*EDPageViewIncrementPosY + EDPageViewOffsetY)];
    
    //animate insert
    [[[pageController view] animator] setFrameOrigin:NSMakePoint(EDPageViewPosX, ([[page pageNumber] intValue]-1)*EDPageViewIncrementPosY + EDPageViewOffsetY)];
    
    // init view after loaded
    [pageController postInit];
    
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewClickedWithoutModifier:) name:EDEventPageClickedWithoutModifier object:pageController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewStartDrag:) name:EDEventPageViewStartDrag object:pageController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeleteKeyPressed:) name:EDEventPagesDeletePressed object:pageController];
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
            [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPagesDeletePressed object:currentPageController];
            
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
    NSArray *pages = [_coreData getAllPages];
    NSArray *selectedPages = [EDPage findAllSelectedObjects];
    
    // do not delete if there will be no pages left
    if (([pages count] - [selectedPages count]) < 1) 
        return;
    
    [_coreData deleteSelectedPages];
    
    // correct page numbers
    [_coreData correctPageNumbersAfterDelete];
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

- (void)onPagesViewFinishedDragged:(NSNotification *)note{
    NSMutableArray *pageViews = [[note userInfo] objectForKey:EDKeyPagesViewDraggedViews];
    int destinationSection = [[[note userInfo] valueForKey:EDKeyPagesViewHighlightedDragSection] intValue];
    
    // get first object
    int sourceSection = [[[(EDPageView *)[pageViews objectAtIndex:0] dataObj] pageNumber] intValue];
    int dragDifference = destinationSection - sourceSection;
    /*
    NSLog(@"=== data to insert");
    for (EDPageView *pageView in pageViews){
        NSLog(@"pageView: deleted:%d data:%@", [[pageView dataObj] isDeleted], [pageView dataObj]);
    }
    
    NSArray *pages = [EDPage findAllObjectsOrderedByPageNumber];
    NSLog(@"===before page count:%ld context:%@", [pages count], [_coreData context]);
    for (EDPage *page in pages){
        NSLog(@"page:%@", page);
        //NSLog(@"pages graph:%@", [[page graphs] class]);
    }*/
    //NSLog(@"page number:%d dragged section:%d", pageNumber, draggedSection);
    // do not insert if dragged section not valid
    if (destinationSection != -1) {
        // remove pages
        [self removePageViews:pageViews];
        
        if (dragDifference < 0) {
            // user is dragging to previous section
            
            // update old page numbers
            //[_coreData updatePageNumbersStartingAt:sourceSection forCount:[pageViews count]];
            //[_coreData updatePageNumbersStartingAt:destinationSection byDifference:[pageViews count] endNumber:sourceSection];
            
            // insert pages into new location
            //NSLog(@"==before inserting page views.");
            //[self insertPageViews:pageViews toPage:destinationSection];
            //NSLog(@"==after inserting page views.");
        }
        else {
            // user is dragging pages forward
            
            // update old page numbers
            //[_coreData updatePageNumbersStartingAt:destinationSection forCount:(-1 * [pageViews count])];
            //[_coreData updatePageNumbersStartingAt:(sourceSection+[pageViews count]) byDifference:([pageViews count] * -1) endNumber:destinationSection];
            
            // insert pages into new location
            //[self insertPageViews:pageViews toPage:(destinationSection - 1)];
        }
        
        /*
        for (EDPageView *pageView in pageViews){
            NSLog(@"pageView: data:%@", [[pageView dataObj] objectID]);
        }
        */
        // print out all pages
        //NSArray *graphs = [_coreData getAllGraphs];
        //NSLog(@"===== getting graphs: count:%ld", [graphs count]);
        //NSLog(@"===begin print all");
        //[EDPage printAll];
        //NSLog(@"===end print all from context:%@", [_coreData context]);
        //NSArray *pages = [EDPage findAllObjectsOrderedByPageNumber];
        /*
        pages = [EDPage findAllObjectsOrderedByPageNumber];
        NSLog(@"===after page count:%ld context:%@", [pages count], [_coreData context]);
        for (EDPage *page in pages){
            NSLog(@"page:%@", page);
            //NSLog(@"pages graph:%@", [[page graphs] class]);
        }*/
        /*
    NSLog(@"=== data to insert");
    for (EDPageView *pageView in pageViews){
        NSLog(@"pageView: deleted:%d data:%@", [[pageView dataObj] isDeleted], [pageView dataObj]);
    }*/
    
        
    }
    else {
        // nothing to insert, user dragged to undraggable location
    }
}

#pragma mark view frame
- (void)updateViewFrameSize{
    NSArray *pages = [_coreData getAllPages];
    
    // update frame height
    NSRect originalFrame = [[self view] frame];
    
    // set frame height to at a minimum the height of the scroll view
    float targetHeight;
    float scrollViewHeight = [[[[self view] superview] superview] frame].size.height;    
    float viewHeight = [pages count] * EDPageViewIncrementPosY;
    
    if (viewHeight < scrollViewHeight)
        targetHeight = scrollViewHeight; 
    else
        targetHeight = viewHeight;
    
    [[[self view] animator] setFrameSize:NSMakeSize(originalFrame.size.width, targetHeight)];
}

#pragma mark window
- (void)onWindowResized:(NSNotification *)note{
    // need to redraw positions
    [self correctPagePositionsAfterUpdateWithoutAnimation];
}
@end
