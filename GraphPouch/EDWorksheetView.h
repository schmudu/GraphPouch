//
//  EDWorksheetView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDWorksheetView : NSView{
    NSMutableDictionary *selectedElements;
    NSNotificationCenter *nc;
    IBOutlet NSArrayController *elements;
}

- (void)onGraphSelected:(NSNotification *)note;
- (BOOL)elementSelected:(id)element;
- (void)loadDataFromManagedObjectContext;

@end
