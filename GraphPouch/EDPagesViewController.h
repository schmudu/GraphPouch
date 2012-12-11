//
//  EDPagesViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDCoreDataUtility.h"
#import "EDDocument.h"

@interface EDPagesViewController : NSViewController{
    NSNotificationCenter *_nc;
    NSMutableArray *_pageControllers;
    IBOutlet EDDocument *_documentController;
    int _startDragSection;
    NSManagedObjectContext *_context;
}
- (void)postInitialize:(NSManagedObjectContext *)context;
- (void)addNewPage;
@end
