//
//  EDWorksheetElementView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/26/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EDElement;

@interface EDWorksheetElementView : NSView{
    @protected
    NSNotificationCenter    *_nc;
    NSPoint                 _lastDragLocation;
    NSPoint                 _lastCursorLocation;
    NSPoint                 _savedMouseSnapLocation;
    BOOL                    _didSnap;
    BOOL                    _didSnapToSourceX;
    BOOL                    _didSnapToSourceY;
    BOOL                    _didSnapToOriginX;
    BOOL                    _didSnapToBottomX;
    BOOL                    _didSnapToOriginY;
    BOOL                    _didSnapToBottomY;
    BOOL                    _mouseUpEventSource;
    int                     _savedZIndex;
    NSManagedObjectContext  *_context;
    //NSView                  *_dragView;
}

@property (nonatomic, strong) id dataObj;

- (void)mouseDraggedBySelection:(NSEvent *)theEvent snapInfo:(NSDictionary *)snapInfo;
- (void)mouseUpBySelection:(NSEvent *)theEvent;
- (void)mouseDownBySelection:(NSEvent *)theEvent;
- (void)onContextChanged:(NSNotification *)note;
- (void)updateDisplayBasedOnContext;
- (void)drawElementAttributes;
- (void)removeFeatures;
- (void)addFeatures;
- (void)unsetZIndexFromDragLayer:(BOOL)updateStage;
@end
