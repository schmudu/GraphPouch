//
//  EDMenuController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/9/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuController.h"
#import "EDConstants.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDPage.h"
#import "NSManagedObject+EasyFetching.h"

@interface EDMenuController()
- (void)onContextChanged:(NSNotification *)note;
@end

@implementation EDMenuController

- (id)initWithContext:(NSManagedObjectContext *)context{
    self = [super init];
    if(self){
        _context = context;
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    return self;
}

- (void)onContextChanged:(NSNotification *)note{
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

@end
