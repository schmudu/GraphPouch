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
#import "EDCoreDataUtility+Pages.h"

@interface EDPagesViewController ()
- (void)onContextChanged:(NSNotification *)note;
- (void)insertPageViews:(NSMutableArray *)pageViews toPage:(int)pageNumber;
- (void)removePages:(NSArray *)pages;
- (void)drawPage:(EDPage *)page;
- (void)removePage:(EDPage *)page;
- (void)correctPagePositionsAfterUpdate;
- (void)correctPagePositionsAfterUpdateWithoutAnimation;
- (void)updatePageNumbersOfDraggedPages:(int)endSection;
- (void)updatePageNumbersOfUndraggedPagesLessThan:(int)upperNumber greaterThanOrEqualTo:(int)lowerNumber;
- (void)updatePageNumbersOfUndraggedPagesGreaterThanOrEqualTo:(int)lowerNumber lessThan:(int)upperNumber;
- (void)deselectAllPages;
- (void)onPageViewClickedWithoutModifier:(NSNotification *)note;
- (void)onPageViewStartDrag:(NSNotification *)note;
- (void)onPagesViewClicked:(NSNotification *)note;
- (void)onDeleteKeyPressed:(NSNotification *)note;
- (void)onWindowResized:(NSNotification *)note;
- (void)onPagesViewFinishedDragged:(NSNotification *)note;
- (void)onPageViewMouseDown:(NSNotification *)note;
- (void)onShortcutCopy:(NSNotification *)note;
- (void)onShortcutCut:(NSNotification *)note;
- (void)onShortcutPaste:(NSNotification *)note;
- (void)updateViewFrameSize;
- (NSArray *)getSelectedPages;
- (BOOL)readFromPasteboard;
@end

@implementation EDPagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pageControllers = [[NSMutableArray alloc] init];
        _nc = [NSNotificationCenter defaultCenter];
        
        // listen
        //[_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:[EDCoreDataUtility context]];
    }
    
    return self;
}

- (void)dealloc{
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [_nc removeObserver:self name:EDEventPagesDeletePressed object:[self view]];
    [_nc removeObserver:self name:EDEventPagesViewClicked object:[self view]];
    [_nc removeObserver:self name:EDEventPageViewsFinishedDrag object:[self view]];
    [_nc removeObserver:self name:EDEventShortcutCopy object:[self view]];
    [_nc removeObserver:self name:EDEventShortcutCut object:[self view]];
    [_nc removeObserver:self name:EDEventShortcutPaste object:[self view]];
    [_nc removeObserver:self name:EDEventWindowDidResize object:_documentController];
}

- (void)postInitialize:(NSManagedObjectContext *)context{
    // init context
    _context = context;
    
    // disable autoresize
    [[self view] setAutoresizesSubviews:FALSE];
    
    // init view
    [(EDPagesView *)[self view] postInitialize:context];
    
    // listen
    [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    
    // listen
    [_nc addObserver:self selector:@selector(onShortcutCopy:) name:EDEventShortcutCopy object:[self view]];
    [_nc addObserver:self selector:@selector(onShortcutCut:) name:EDEventShortcutCut object:[self view]];
    [_nc addObserver:self selector:@selector(onShortcutPaste:) name:EDEventShortcutPaste object:[self view]];
    [_nc addObserver:self selector:@selector(onPagesViewClicked:) name:EDEventPagesViewClicked object:[self view]];
    [_nc addObserver:self selector:@selector(onDeleteKeyPressed:) name:EDEventPagesDeletePressed object:[self view]];
    [_nc addObserver:self selector:@selector(onPagesViewFinishedDragged:) name:EDEventPageViewsFinishedDrag object:[self view]];
    [_nc addObserver:self selector:@selector(onWindowResized:) name:EDEventWindowDidResize object:_documentController];
    
    NSArray *pages = [EDCoreDataUtility getAllPages:_context];
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
    
}

#pragma mark page CRUD
- (void)insertPageViews:(NSMutableArray *)pageViews toPage:(int)pageNumber{
    EDPage *newPage;
    int currentPageNumber = pageNumber;
    
    // insert new pages
    for (EDPageView *pageView in pageViews){
        newPage = [pageView dataObj];
        
        // set page number
        [newPage setPageNumber:[[NSNumber alloc] initWithInt:currentPageNumber]];
        
#warning need to figure out this after we set up core data relationships 
        currentPageNumber++;
    }
}
    
- (void)removePages:(NSArray *)pages{
    for (EDPage *page in pages){
        [EDCoreDataUtility removePage:page context:_context];
    }
}

- (void)addNewPage{
    // create new page
    NSArray *pages = [EDCoreDataUtility getAllPages:_context];
    //EDPage *newPage = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[EDCoreDataUtility context]] insertIntoManagedObjectContext:[EDCoreDataUtility context]];
    EDPage *newPage = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    
    // if no other pages then set this page to be the first one
    if ([pages count] == 0) {
        [newPage setPageNumber:[[NSNumber alloc] initWithInt:1]];
        [newPage setCurrentPage:TRUE];
    }
    else {
        EDPage *lastPage = [EDCoreDataUtility getLastSelectedPage:_context];
        if (lastPage) {
            NSArray *pagesNeedUpdating = [EDCoreDataUtility getPagesWithPageNumberGreaterThan:[[lastPage pageNumber] intValue] context:_context];
            
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
}

- (void)onContextChanged:(NSNotification *)note{
    NSArray *insertedArray = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    int entityDeleted = FALSE;
    
    for (NSManagedObject *addedObject in insertedArray){
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewMouseDown:) name:EDEventPageViewMouseDown object:pageController];
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
            [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPageViewMouseDown object:currentPageController];
            
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
    NSArray *selectedPageViews = [self getSelectedPages];
    
    // copy all page views that are selected to the pasteboard
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:[NSArray arrayWithArray:selectedPageViews]];
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

- (void)onPageViewMouseDown:(NSNotification *)note{
    _startDragSection = [[[(EDPageView *)[[note userInfo] objectForKey:EDKeyPageViewData] dataObj] pageNumber] intValue];
}

#pragma mark pages events
- (void)onDeleteKeyPressed:(NSNotification *)note{
    NSArray *pages = [EDCoreDataUtility getAllPages:_context];
    NSArray *selectedPages = [EDPage getAllSelectedObjects:_context];
    
    // do not delete if there will be no pages left
    if (([pages count] - [selectedPages count]) < 1) 
        return;
    
    [EDCoreDataUtility deleteSelectedPages:_context];
    
    // correct page numbers
    [EDCoreDataUtility correctPageNumbersAfterDelete:_context];
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

- (void)updatePageNumbersOfUndraggedPagesLessThan:(int)upperNumber greaterThanOrEqualTo:(int)lowerNumber{
    // get selected pages
    NSArray *unselectedPages = [EDCoreDataUtility getUnselectedPagesWithPageNumberLessThan:upperNumber greaterThanOrEqualTo:lowerNumber context:_context];
    
    // if no unselected pages then exit
    if ([unselectedPages count] == 0) {
        return;
    }
    
    // sort selected pages by page number
    NSArray *sortedArray;
    sortedArray = [unselectedPages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        // sort array by page number
        NSNumber *first = [(EDPage *)a pageNumber];
        NSNumber *second = [(EDPage *)b pageNumber];
        return [first compare:second];
    }]; 
    
    // iterate through pages and set their page number accordingly
    NSArray *selectedPages;
    for (EDPage *page in sortedArray){
        selectedPages= [EDCoreDataUtility getSelectedPagesWithPageNumberLessThan:[[page pageNumber] intValue] greaterThanOrEqualTo:lowerNumber context:_context];
        [page setPageNumber:[[NSNumber alloc] initWithInt:([[page pageNumber] intValue] - [selectedPages count])]];
    }
}

- (void)updatePageNumbersOfUndraggedPagesGreaterThanOrEqualTo:(int)lowerNumber lessThan:(int)upperNumber{
    // get selected pages
    NSArray *unselectedPages = [EDCoreDataUtility getUnselectedPagesWithPageNumberGreaterThanOrEqualTo:lowerNumber lessThan:upperNumber context:_context];
    
    // if no unselected pages then exit
    if ([unselectedPages count] == 0) {
        return;
    }
    
    // sort selected pages by page number
    NSArray *sortedArray;
    sortedArray = [unselectedPages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        // sort array by page number
        NSNumber *first = [(EDPage *)a pageNumber];
        NSNumber *second = [(EDPage *)b pageNumber];
        return [first compare:second];
    }]; 
    
    // iterate through pages and set their page number accordingly
    NSArray *selectedPages;
    for (EDPage *page in sortedArray){
        selectedPages= [EDCoreDataUtility getSelectedPagesWithPageNumberGreaterThanOrEqualTo:[[page pageNumber] intValue] lessThan:(upperNumber+1) context:_context];       
        [page setPageNumber:[[NSNumber alloc] initWithInt:([[page pageNumber] intValue] + [selectedPages count])]];
    }
}

- (void)updatePageNumbersOfDraggedPages:(int)endSection{
    // get selected pages
    NSArray *selectedPages = [EDPage getAllSelectedObjects:_context];
    
    // if no unselected pages then exit
    if ([selectedPages count] == 0) {
        return;
    }
    // sort selected pages by page number
    NSArray *sortedArray;
    sortedArray = [selectedPages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        // sort array by page number
        NSNumber *first = [(EDPage *)a pageNumber];
        NSNumber *second = [(EDPage *)b pageNumber];
        return [first compare:second];
    }]; 
    
    // iterate through pages and set their page number accordingly
    int pageNumber = endSection;
    for (EDPage *page in sortedArray){
        [page setPageNumber:[[NSNumber alloc] initWithInt:pageNumber]];
        pageNumber++;
    }
}

- (NSArray *)getSelectedPages{
    NSMutableArray *selectedPages = [[NSMutableArray alloc] init];
    
     // iterate through page controllers and add to array if it's selected
    for (EDPageViewController *pageController in _pageControllers){
        if ([[(EDPageView *)[pageController view] dataObj] selected] == TRUE) {
            [selectedPages addObject:[(EDPageView *)[pageController view] dataObj]];
        }
    }
    
    return selectedPages;
}

- (void)onPagesViewFinishedDragged:(NSNotification *)note{
    NSMutableArray *pageViews = [[note userInfo] objectForKey:EDKeyPagesViewDraggedViews];
    int destinationSection = [[[note userInfo] valueForKey:EDKeyPagesViewHighlightedDragSection] intValue];
    int firstSelectedPageSection = [[(EDPage *)[[note userInfo] valueForKey:EDKeySelectedPageFirst] pageNumber] intValue];
    int lastSelectedPageSection = [[(EDPage *)[[note userInfo] valueForKey:EDKeySelectedPageLast] pageNumber] intValue];
    
    // do not insert if dragged section not valid
    if (destinationSection != -1) {
        // remove pages that were dragged
        //[self removePages:pageViews];
//#error I think i need to add the pages here
        
        // update undragged pages
        [self updatePageNumbersOfUndraggedPagesLessThan:destinationSection greaterThanOrEqualTo:firstSelectedPageSection];
        [self updatePageNumbersOfUndraggedPagesGreaterThanOrEqualTo:destinationSection lessThan:lastSelectedPageSection];
        
        // update dragged pages
        NSArray *selectedPagesLessThanDestination = [EDCoreDataUtility getSelectedPagesWithPageNumberLessThan:destinationSection greaterThanOrEqualTo:firstSelectedPageSection context:_context];
        [self updatePageNumbersOfDraggedPages:(destinationSection - [selectedPagesLessThanDestination count])];
    }
    else {
        // nothing to insert, user dragged to undraggable location
    }
}

#pragma mark keyboard
- (void)onShortcutCut:(NSNotification *)note{
    NSArray *selectedPages = [EDPage getAllSelectedObjectsOrderedByPageNumber:_context];
    NSArray *allPages = [EDPage getAllObjects:_context];
    NSError *error;
    
    // if there will no pages left if all pages are cut, then do not allow this operation
    if ([allPages count] - [selectedPages count] < 1) 
        return;
    
    // get last selected page which we will use to designate which page should be used
    int lastSelectedPageNumber = [[(EDPage *)[selectedPages lastObject] pageNumber] intValue]; 
    
    // set page after selected pages as the currently viewed page
    NSArray *pagesAfterLastSelectedPage = [EDCoreDataUtility getPagesWithPageNumberGreaterThan:lastSelectedPageNumber context:_context];
    
    if ([pagesAfterLastSelectedPage count] > 0){
        // set the next unselected page as current
        [EDCoreDataUtility setPageAsCurrent:(EDPage *)[pagesAfterLastSelectedPage objectAtIndex:0] context:_context];
        
        // save so that context changes and worksheet view updates
        [_context save:&error];
    }
    else {
        // set the previous unselected page as current
        NSArray *pagesBeforeLastSelectedPage = [EDCoreDataUtility getUnselectedPagesWithPageNumberLessThan:lastSelectedPageNumber greaterThanOrEqualTo:0 context:_context];
        [EDCoreDataUtility setPageAsCurrent:(EDPage *)[pagesBeforeLastSelectedPage lastObject] context:_context];
        
        // save so that context changes and worksheet view updates
        [_context save:&error];
    }
    
    // copy all page views that are selected to the pasteboard
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:[NSArray arrayWithArray:selectedPages]];
    
    // now cut all selected views
    [self removePages:selectedPages];
    
     // update page numbers
    [EDCoreDataUtility correctPageNumbersAfterDelete:_context];
    
    // update location
    [self correctPagePositionsAfterUpdate];
}

- (void)onShortcutCopy:(NSNotification *)note{
    NSArray *selectedPageViews = [self getSelectedPages];
    
    // copy all page views that are selected to the pasteboard
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:[NSArray arrayWithArray:selectedPageViews]];
}

- (void)onShortcutPaste:(NSNotification *)note{
    // read objects from pasteboard
    [self readFromPasteboard];
}

#pragma mark pasteboard
- (BOOL)readFromPasteboard{
    
    // get last selected object
    NSArray *selectedPages = [EDPage getAllSelectedObjectsOrderedByPageNumber:_context];
    EDPage *lastSelectedPage = (EDPage *)[selectedPages lastObject];
    int insertPosition, startInsertPosition;
    if (lastSelectedPage){
        startInsertPosition = [[lastSelectedPage pageNumber] intValue] + 1;
    }
    else {
        // append pages 
        startInsertPosition = [[EDPage getAllObjects:_context] count] + 1;
    }
    
    // save position
    insertPosition = startInsertPosition;
    
    NSArray *pages = [EDPage getAllObjects:_context];
    NSLog(@"pages before insert:%@", pages);
    NSArray *classes = [NSArray arrayWithObject:[EDPage class]];
    NSArray *objects = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:nil];
    // update page numbers of inserted objects
    if ([objects count] > 0) {
        // cycle through objects and insert after last selected page
        for (EDPage *page in objects){
#warning need to insert page into context and set up the relationships?
            [_context insertObject:page];
            
            // update each page view with it's new position
            [page setPageNumber:[[NSNumber alloc] initWithInt:insertPosition]];
            insertPosition++;
        }
        // retrieve pages that we will need to update after inserting the pasted pages
        NSArray *postPages = [EDCoreDataUtility getUnselectedPagesWithPageNumberGreaterThanOrEqualTo:startInsertPosition context:_context];
        
        // update each page view with it's new position
        for (EDPage *page in postPages){
            [page setPageNumber:[[NSNumber alloc] initWithInt:insertPosition]];
            insertPosition++;
        }
        pages = [EDPage getAllObjects:_context];
        NSLog(@"pages after insert:%@", pages);
        return YES;
    }
    return NO;
}

#pragma mark view frame
- (void)updateViewFrameSize{
    NSArray *pages = [EDCoreDataUtility getAllPages:_context];
    
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
