//
//  EDPageViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPage.h"

@interface EDPageViewController : NSViewController{
    IBOutlet NSTextField *pageLabel;
#warning does this need to be a weak assignment?
    EDPage *_pageData;
}

- (void)deselectPage;
- (id)initWithPage:(EDPage *)page;
- (void)postInit;
@end
