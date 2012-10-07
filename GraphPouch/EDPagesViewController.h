//
//  EDPagesViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDCoreDataUtility.h"

@interface EDPagesViewController : NSViewController{
    NSNotificationCenter *_nc;
    EDCoreDataUtility *_coreData;
    NSMutableArray *_pageControllers;
}
- (void)postInitialize;
- (void)addNewPage;
@end
