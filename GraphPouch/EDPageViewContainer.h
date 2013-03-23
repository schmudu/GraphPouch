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
    NSMutableArray *_textboxViews;
    //NSMutableArray *_graphViews;
    NSMutableArray *_graphCacheViews;
    NSMutableArray *_lineCacheViews;
}

+ (NSRect)containerFrame;
- (id)initWithFrame:(NSRect)frame page:(EDPage *)page;
- (void)postInit;
@end
