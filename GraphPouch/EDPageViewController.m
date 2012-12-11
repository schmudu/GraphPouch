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
#import "EDPage.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDPageViewController ()
- (void)onPageViewClickedWithoutModifier:(NSNotification *)note;
- (void)onPageViewStartDrag:(NSNotification *)note;
- (void)onContextChanged:(NSNotification *)note;
- (void)onDeleteKeyPressed:(NSNotification *)note;
- (void)onPageViewMouseDown:(NSNotification *)note;
@end

@implementation EDPageViewController

- (id)initWithPage:(EDPage *)page{
    self = [super initWithNibName:@"EDPageView" bundle:nil];
    if (self) {
        _pageData = page;
        _context = [page managedObjectContext];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeleteKeyPressed:) name:EDEventPagesDeletePressed object:[self view]];
    }
    
    return self;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPageClickedWithoutModifier object:[self view]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPageViewStartDrag object:[self view]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPagesDeletePressed object:[self view]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventPageViewMouseDown object:[self view]];
}

- (EDPage *)dataObj{
    return _pageData;
}

- (void)postInit{
    // set data obj
    [(EDPageView *)[self view] setDataObj:_pageData];
    
    // set page label
    [pageLabel setStringValue:[[NSString alloc] initWithFormat:@"%@", [_pageData pageNumber]]];
    
    // listen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewClickedWithoutModifier:) name:EDEventPageClickedWithoutModifier object:[self view]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewStartDrag:) name:EDEventPageViewStartDrag object:[self view]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewMouseDown:) name:EDEventPageViewMouseDown object:[self view]];
}

#pragma mark events
- (void)onPageViewMouseDown:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageViewMouseDown object:self userInfo:[note userInfo]];
}

- (void)onDeleteKeyPressed:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPagesDeletePressed object:self];
    /*
    NSArray *pages = [EDCoreDataUtility getAllPages];
    NSArray *selectedPages = [EDPage getAllSelectedObjects];
    
    // do not delete if there will be no pages left
    if (([pages count] - [selectedPages count]) < 1) 
        return;
    
    [EDCoreDataUtility deleteSelectedPages];
     */
}

- (void)onPageViewStartDrag:(NSNotification *)note{
    NSMutableDictionary *eventInfo = [[NSMutableDictionary alloc] init];
    [eventInfo setObject:_pageData forKey:EDKeyPageViewData];
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventPageViewStartDrag object:self userInfo:eventInfo];
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
