//
//  EDPageViewContainerTextView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 3/14/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDTextbox.h"

@interface EDPageViewContainerTextView : NSView{
    EDTextbox *_textbox;
    NSManagedObjectContext *_context;
}

- (id)initWithFrame:(NSRect)frame textbox:(EDTextbox *)textbox context:(NSManagedObjectContext *)context;
@end
