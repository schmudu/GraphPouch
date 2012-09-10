//
//  EDMenuWindowController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDCoreDataUtility.h"

@interface EDMenuWindowController : NSViewController <NSMenuDelegate>{
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
    EDCoreDataUtility *_coreData;
    IBOutlet NSMenuItem *properties;
}

- (void)initWindowAfterLoaded;
@end
