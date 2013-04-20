//
//  EDTextboxViewMask.h
//  GraphPouch
//
//  Created by PATRICK LEE on 2/2/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDTextboxViewMask : NSView{
    BOOL _drawSelection;
}

- (id)initWithFrame:(NSRect)frame drawSelection:(BOOL)drawSelection;
- (void)postInit;
@end
