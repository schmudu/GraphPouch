//
//  EDMenuWindowController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuWindowController.h"
#import "EDMenuWindowPropertiesController.h"
#import "EDConstants.h"

@interface EDMenuWindowController ()

@end

@implementation EDMenuWindowController

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

- (void)menuWillOpen:(NSMenu *)menu{
    NSLog(@"menu did open.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:EDPreferencePropertyPanel]) {
        [properties setState:NSOnState];
    }
    else {
        [properties setState:NSOffState];
    }
}


- (void)initWindowAfterLoaded{
    NSLog(@"init window base class.");
}

@end
