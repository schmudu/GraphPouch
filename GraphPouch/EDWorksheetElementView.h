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
}
//@property (nonatomic, strong) EDElement *dataObj;
@property (nonatomic, strong) id dataObj;
@property NSString *viewID;

+ (NSString *)generateID;
- (void)mouseDraggedBySelection:(NSEvent *)theEvent;
- (void)mouseUpBySelection:(NSEvent *)theEvent;
- (void)mouseDownBySelection:(NSEvent *)theEvent;
- (void)snapToPoint:(float)snapOffset;

@end
