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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        _context = [_coreData context];
        _nc = [NSNotificationCenter defaultCenter];
    }
    
    return self;
}

- (void)initWindowAfterLoaded{
    NSLog(@"init window base class.");
}

@end
