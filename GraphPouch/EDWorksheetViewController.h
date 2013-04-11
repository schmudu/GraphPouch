//
//  EDWorksheetControllerViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDDocument.h"

//@class EDWorksheetView;

@interface EDWorksheetViewController : NSViewController{
    NSNotificationCenter *_nc;
    IBOutlet EDDocument *_documentController;
    NSManagedObjectContext *_context;
    NSManagedObjectContext *_copyContext;
}
- (void)postInitialize:(NSManagedObjectContext *)context copyContext:(NSManagedObjectContext *)copyContext;
- (void)onPagesWillBeRemoved:(NSArray *)pagesToDelete;
- (void)addNewExpression;
- (void)addNewGraph;
- (void)addNewLine;
- (void)addNewTextbox;
- (void)addLabelName;
- (void)addLabelDate;
@end
