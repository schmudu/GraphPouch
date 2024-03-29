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
#import "EDTextboxViewMask.h"
@class EDTextbox;

@interface EDTextboxView : EDWorksheetElementView <NSTextViewDelegate, NSTextStorageDelegate>{
    EDTextView *_textView;
    EDTextboxViewMask *_mask;
    BOOL _enabled;
}

- (id)initWithFrame:(NSRect)frame textboxModel:(EDTextbox *)myTextbox drawSelection:(BOOL)drawSelection;
- (BOOL)enabled;
- (void)postInit;
- (void)disable;
@end
