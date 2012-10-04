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
@end

@implementation EDPagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _nc = [NSNotificationCenter defaultCenter];
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        
        // listen
        [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:[_coreData context]];
    }
    
    return self;
}

- (void)postInitialize{
    NSArray *pages = [_coreData getAllPages];
    
    // if no pages then we need to create one
    if([pages count] == 0){
        [self addNewPage];
    }
    else{
        // else draw the pages that already exist
        NSLog(@"we need to draw the pages");
    }
}


- (void)addNewPage{
    // create new page
    NSArray *pages = [_coreData getAllPages];
    //NSLog(@"page count:%ld", [pages count]);
    EDPage *newPage = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[_coreData context]] insertIntoManagedObjectContext:[_coreData context]];
    //[[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[_coreData context]] insertIntoManagedObjectContext:[_coreData context]];
    NSArray *newPages = [_coreData getAllPages];
    //NSLog(@"new page count:%ld", [newPages count]);
    
    // add it to context
    //[[_coreData context] insertObject:newPage];
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
    NSLog(@"going to draw page");
    EDPageViewController *pageController = [[EDPageViewController alloc] initWithNibName:@"EDPageViewController" bundle:nil];
    //EDPageView *pageView = [[EDPageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    
    // set view
    //[pageController setView:pageView];
    
    // add to view
    [[self view] addSubview:[pageController view]];
}
@end
