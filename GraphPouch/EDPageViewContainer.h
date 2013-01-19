//
//  EDPageViewContainer.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/19/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPage.h"

@interface EDPageViewContainer : NSView{
    EDPage *_page;
    NSManagedObjectContext *_context;
}

- (id)initWithFrame:(NSRect)frame page:(EDPage *)page;
@end
