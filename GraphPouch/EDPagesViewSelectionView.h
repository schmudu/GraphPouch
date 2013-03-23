//
//  EDPagesViewSelectionView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 3/22/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDPagesViewSelectionView : NSView{
    NSPoint _mousePointDown;
    NSPoint _mousePointDrag;
}

- (void)resetPoints;
- (void)setMouseDragPoint:(NSPoint)mouseDragPoint mouseDownPoint:(NSPoint)mouseDownPoint;
@end
