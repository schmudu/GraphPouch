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
#import "EDCoreDataUtility.h"

@interface EDWorksheetViewController ()

@end

@implementation EDWorksheetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _nc = [NSNotificationCenter defaultCenter];
        _context = [[EDCoreDataUtility sharedCoreDataUtility] context];
        
        // listen
        NSLog(@"init worksheet view controller.");
    }
    
    return self;
}

- (void)loadDataFromManageObjectContext{
    NSLog(@"going to init worksheet view controller.");
    //[(EDWorksheetView *)[self view] loadDataFromManagedObjectContext];
    
    //listen
    //[nc addObserver:self selector:@selector(onWorksheetClicked:) name:EDEventWorksheetClicked object:[self view]];
}

- (void)initListeners{
    [_nc addObserver:self selector:@selector(onWorksheetClicked:) name:EDEventWorksheetClicked object:[self view]];
}

- (void)onWorksheetClicked:(NSNotification *)note{
    NSLog(@"worksheet clicked.");
    // clear all the selected elements
    //EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    //[coreData clearSelectedElements];
    [[EDCoreDataUtility sharedCoreDataUtility] clearSelectedElements];
}

- (void)dealloc{
    [_nc removeObserver:self name:EDEventWorksheetClicked object:[self view]];
}

@end
