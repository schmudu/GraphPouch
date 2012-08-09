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

@interface EDWorksheetViewController ()

@end

@implementation EDWorksheetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)loadDataFromManageObjectContext{
    NSLog(@"going to init worksheet view controller.");
    //[(EDWorksheetView *)[self view] loadDataFromManagedObjectContext];
    
    //listen
    //[nc addObserver:self selector:@selector(onWorksheetClicked:) name:EDEventWorksheetClicked object:[self view]];
}

- (void)onWorksheetClicked:(NSNotification *)note{
    NSLog(@"worksheet clicked.");
}

@end
