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
    NSPoint                 lastDragLocation;
    NSPoint                 lastCursorLocation;
    NSPoint                 _savedMouseSnapLocation;
    BOOL                    _didSnap;
    BOOL                    _didSnapToSourceX;
    BOOL                    _didSnapToSourceY;
}

@property (nonatomic, strong) id dataObj;
@property NSString *viewID;

+ (NSString *)generateID;
- (void)mouseDraggedBySelection:(NSEvent *)theEvent snapInfo:(NSDictionary *)snapInfo;
- (void)mouseUpBySelection:(NSEvent *)theEvent;
- (void)mouseDownBySelection:(NSEvent *)theEvent;
- (void)onContextChanged:(NSNotification *)note;
- (void)updateDisplayBasedOnContext;

@end
