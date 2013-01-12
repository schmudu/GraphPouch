//
//  EDWindow.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/19/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDWindow.h"
#import "EDConstants.h"

@implementation EDWindow

- (void)postInitialize:(NSManagedObjectContext *)context{
    _context = context;
}

- (void)close{
    [super close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventWindowWillClose object:self];
}

@end
