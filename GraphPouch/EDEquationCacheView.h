//
//  EDEquationCacheView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/6/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDEquationCacheView : NSView{
    NSImage *_equationImage;
}

- (id)initWithFrame:(NSRect)frame equationImage:(NSImage *)equationImage;
@end
