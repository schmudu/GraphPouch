//
//  EDPageViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPageViewController.h"

@interface EDPageViewController ()

@end

@implementation EDPageViewController

- (id)initWithPage:(EDPage *)page{
    self = [super initWithNibName:@"EDPageView" bundle:nil];
    if (self) {
        pageData = page;
        NSLog(@"init page view controller: view:%@", [self view]);
    }
    
    return self;
}

- (void)postInit{
    [pageLabel setStringValue:[[NSString alloc] initWithFormat:@"%@", [pageData pageNumber]]];
    //NSLog(@"init page view controller: page number:%@ page label:%@", [pageData pageNumber], pageLabel);
    
}

@end
