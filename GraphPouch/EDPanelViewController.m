//
//  EDPanelViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/10/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPanelViewController.h"

@interface EDPanelViewController ()

@end

@implementation EDPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _context = context;
        _nc = [NSNotificationCenter defaultCenter];
    }
    
    return self;
}

- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context{
    // init code
}

@end
