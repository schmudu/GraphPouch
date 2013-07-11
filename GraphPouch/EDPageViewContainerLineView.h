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
    NSManagedObjectContext *_context;
}

- (id)initWithFrame:(NSRect)frame line:(EDLine *)line context:(NSManagedObjectContext *)context;
- (EDLine *)line;
@end
