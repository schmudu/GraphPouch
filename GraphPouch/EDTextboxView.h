//
//  EDTextboxView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDWorksheetElementView.h"
#import "EDTextView.h"
@class EDTextbox;

@interface EDTextboxView : EDWorksheetElementView{
    EDTextView *_textView;
    NSView *_mask;
    BOOL _enabled;
}

- (id)initWithFrame:(NSRect)frame textboxModel:(EDTextbox *)myTextbox;
- (BOOL)enabled;
//- (void)toggle;
@end
