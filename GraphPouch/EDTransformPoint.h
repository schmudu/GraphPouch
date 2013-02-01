//
//  EDTransformPoint.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDTransformPoint : NSView{
    @protected
    BOOL _mouseIsOver;
    BOOL _didSnap;
    NSNotificationCenter    *_nc;
    NSPoint                 _lastDragLocation;
    NSPoint                 _lastCursorLocation;
    NSPoint                 _savedMouseSnapLocation;
}

- (float)findClosestPoint:(float)currentPoint guides:(NSMutableArray *)guides;

@property NSString *transformCorner;
@end
