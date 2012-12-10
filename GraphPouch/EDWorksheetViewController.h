//
//  EDWorksheetControllerViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDCoreDataUtility.h"
#import "EDDocument.h"

//@class EDWorksheetView;

@interface EDWorksheetViewController : NSViewController{
    NSNotificationCenter *_nc;
    EDCoreDataUtility *_coreData;
    IBOutlet EDDocument *_documentController;
    NSManagedObjectContext *_context;
}
- (void)postInitialize:(NSManagedObjectContext *)context;
- (void)addNewGraph;

@end
