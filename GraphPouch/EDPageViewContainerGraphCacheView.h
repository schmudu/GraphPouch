//
//  EDPageViewContainerGraphCacheView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 3/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDPageViewContainerGraphCacheView : NSView{
    NSImage *_graphImage;
}

- (id)initWithFrame:(NSRect)frame graphImage:(NSImage *)graphImage;
@end
