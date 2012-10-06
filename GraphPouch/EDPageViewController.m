//
//  EDPageViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPageViewController.h"
#import "EDPageView.h"

@interface EDPageViewController ()

@end

@implementation EDPageViewController

- (id)initWithPage:(EDPage *)page{
    self = [super initWithNibName:@"EDPageView" bundle:nil];
    if (self) {
        pageData = page;
        //NSLog(@"init page view controller: view:%@", [self view]);
    }
    
    return self;
}

- (void)postInit{
    // set data obj
    [(EDPageView *)[self view] setDataObj:pageData];
    
    // set page label
    [pageLabel setStringValue:[[NSString alloc] initWithFormat:@"%@", [pageData pageNumber]]];
}

@end
