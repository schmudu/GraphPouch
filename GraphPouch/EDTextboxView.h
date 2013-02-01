//
//  EDTextboxView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDWorksheetElementView.h"
@class EDTextbox;

@interface EDTextboxView : EDWorksheetElementView{
    NSTextView *_textView;
}

- (id)initWithFrame:(NSRect)frame textboxModel:(EDTextbox *)myTextbox;
@end
