//
//  EDPageViewContainerLineView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 3/18/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDLine.h"

@interface EDPageViewContainerLineView : NSView{
    EDLine *_line;
}

- (id)initWithFrame:(NSRect)frame line:(EDLine *)line;
@end
