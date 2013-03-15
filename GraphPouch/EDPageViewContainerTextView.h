//
//  EDPageViewContainerTextView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 3/14/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDPageViewContainerTextView : NSView{
    NSImage *_textImage;
    float _xRatio;
    float _yRatio;
}

- (id)initWithFrame:(NSRect)frame textImage:(NSImage *)textImage xRatio:(float)xRatio yRatio:(float)yRatio;
@end
