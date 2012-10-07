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
#import "EDConstants.h"
#import "EDPageViewController.h"

@interface EDPagesViewController ()
- (void)onContextChanged:(NSNotification *)note;
- (void)drawPage:(EDPage *)page;
- (void)deselectAllPages;
- (void)onPageViewClickedWithoutModifier:(NSNotification *)note;
- (void)onPagesViewClicked:(NSNotification *)note;
- (void)onDeleteKeyPressed:(NSNotification *)note;
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
    
    // listen
    [_nc addObserver:self selector:@selector(onPagesViewClicked:) name:EDEventPagesViewClicked object:[self view]];
    [_nc addObserver:self selector:@selector(onDeleteKeyPressed:) name:EDEventPagesDeletePressed object:[self view]];
}


- (void)addNewPage{
    // create new page
    NSArray *pages = [_coreData getAllPages];
    //NSLog(@"page count:%ld", [pages count]);
    EDPage *newPage = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[_coreData context]] insertIntoManagedObjectContext:[_coreData context]];
    //[[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[_coreData context]] insertIntoManagedObjectContext:[_coreData context]];
    
    // if no other pages then set this page to be the first one
    if ([pages count] == 0) {
        [newPage setPageNumber:[[NSNumber alloc] initWithInt:1]];
    }
    else {
        EDPage *lastPage = [_coreData getLastSelectedPage];
        //NSLog(@"more than 1 page count:%ld page number:%@ last page:%@", [pages count], [newPage pageNumber], lastPage);
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
    
    for (NSObject *addedObject in insertedArray){
        if ([[addedObject className] isEqualToString:EDEntityNamePage]) {
            [self drawPage:(EDPage *)addedObject];
        }
    }
}

- (void)drawPage:(EDPage *)page{
    NSArray *currentPages = [_coreData getAllPages];
    //NSLog(@"got all pages: going to draw page: page count:%ld page number:%@", [currentPages count], [page pageNumber]);
    
    EDPageViewController *pageController = [[EDPageViewController alloc] initWithPage:page];
 
    // add controller to array so we can iterate through them
#warning need to release controller if we remove the view
    [_pageControllers addObject:pageController];
    
    // add to view
    [[self view] addSubview:[pageController view]];
    
    //position it
    [[pageController view] setFrameOrigin:NSMakePoint(20, [[page pageNumber] intValue]*80)];
    
    // init view after loaded
    [pageController postInit];
    
    // listen
#warning need to remove this observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewClickedWithoutModifier:) name:EDEventPageClickedWithoutModifier object:pageController];
}

#pragma mark page events
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
    NSLog(@"need to remove selected pages.");
}

@end
