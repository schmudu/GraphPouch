//
//  EDPageViewContainerLineCacheView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 3/18/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDPageViewContainerLineCacheView : NSView{
    NSImage *_lineImage;
}

- (id)initWithFrame:(NSRect)frame lineImage:(NSImage *)lineImage;
@end
