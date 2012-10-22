//
//  EDWorksheetControllerViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDCoreDataUtility.h"
//@class EDWorksheetView;

@interface EDWorksheetViewController : NSViewController{
    NSNotificationCenter *_nc;
    EDCoreDataUtility *_coreData;
}
- (void)postInitialize;
- (void)addNewGraph;

@end
