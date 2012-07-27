//
//  EDDocument.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EDWorksheetViewController;

@interface EDDocument : NSPersistentDocument{
    IBOutlet NSArrayController *elementsController;
}

//- (void)setWorksheetElements:(NSArray *)elements;

@end
