//
//  EDWorksheetView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "EDDocument.h"
//#import "EDCoreDataUtility.h"

@interface EDWorksheetView : NSView{
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
}
@end
