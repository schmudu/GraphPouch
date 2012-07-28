//
//  EDWorksheetControllerViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDWorksheetViewController.h"
#import "EDWorksheetView.h"

@interface EDWorksheetViewController ()

@end

@implementation EDWorksheetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Init code
    }
    
    return self;
}

- (void)loadDataFromManageObjectContext{
    //NSLog(@"going to load data: view: %@", [self view]);
    [(EDWorksheetView *)[self view] loadDataFromManagedObjectContext];
}

@end
