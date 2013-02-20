//
//  EDWorksheetView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPage.h"
#import "EDTextboxView.h"

@interface EDWorksheetView : NSView{
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
    NSMutableDictionary *_guides;
    NSMutableDictionary *_transformRects;
    NSMutableDictionary *_elementsWithTransformRects;
    BOOL _mouseIsDown;
    BOOL _elementIsBeingModified;
    NSPoint _transformRectDragPoint;
    EDPage *_currentPage;
    EDTextboxView *_currentTextView;
    EDWorksheetElementView *_currentDraggedView;
}

/*
- (IBAction)cut:(id)sender;
- (IBAction)paste:(id)sender;
 */
- (void)postInitialize:(NSManagedObjectContext *)context;
- (void)drawLoadedObjects;
- (NSMutableDictionary *)guides;
- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)deselectAll:(id)sender;
@end
