//
//  EDPageViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPageViewController.h"
#import "EDPageView.h"
#import "EDConstants.h"

@interface EDPageViewController ()
- (void)onPageViewClickedWithoutModifier:(NSNotification *)note;
- (void)onContextChanged:(NSNotification *)note;
@end

@implementation EDPageViewController

- (id)initWithPage:(EDPage *)page{
    self = [super initWithNibName:@"EDPageView" bundle:nil];
    if (self) {
        _pageData = page;
        _coreData = [EDCoreDataUtility sharedCoreDataUtility];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:[_coreData context]];
    }
    
    return self;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[_coreData context]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPageClickedWithoutModifier object:[self view]];
}

- (void)postInit{
    // set data obj
    [(EDPageView *)[self view] setDataObj:_pageData];
    
    // set page label
    [pageLabel setStringValue:[[NSString alloc] initWithFormat:@"%@", [_pageData pageNumber]]];
    
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewClickedWithoutModifier:) name:EDEventPageClickedWithoutModifier object:[self view]];
}

- (void)onPageViewClickedWithoutModifier:(NSNotification *)note{
    // dispatch event
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageClickedWithoutModifier object:self];
}

- (void)deselectPage{
    [(EDPageView *)[self view] deselectPage];
}

- (void)onContextChanged:(NSNotification *)note{
    [pageLabel setStringValue:[[NSString alloc] initWithFormat:@"%@", [_pageData pageNumber]]];
}
@end
