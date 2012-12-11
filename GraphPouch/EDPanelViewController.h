//
//  EDPanelViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/10/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDPanelViewController : NSViewController{
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
}
- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context;

@end
