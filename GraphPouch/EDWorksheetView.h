//
//  EDWorksheetView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "EDDocument.h"
#import "EDCoreDataUtility.h"

@interface EDWorksheetView : NSView{
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
    EDCoreDataUtility *_coreData;
    NSMutableDictionary *_guides;
    NSMutableDictionary *_transformRects;
    NSMutableDictionary *_elementsWithTransformRects;
    BOOL _mouseIsDown;
    BOOL _elementIsBeingModified;
    NSPoint _transformRectDragPoint;
}

- (void)drawLoadedObjects;
- (NSMutableDictionary *)guides;

@end
