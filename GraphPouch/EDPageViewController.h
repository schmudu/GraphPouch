//
//  EDPageViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPage.h"
#import "EDCoreDataUtility.h"

@interface EDPageViewController : NSViewController{
    IBOutlet NSTextField *pageLabel;
    EDPage *_pageData;
    EDCoreDataUtility *_coreData;
}
- (EDPage *)dataObj;
- (void)deselectPage;
- (id)initWithPage:(EDPage *)page;
- (void)postInit;
@end
