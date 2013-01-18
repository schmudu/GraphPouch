//
//  EDWorksheetScrollView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDWorksheetClipView.h"

@interface EDWorksheetScrollView : NSScrollView{
    EDWorksheetClipView *_clipView;
}

- (void)postInitialize;
- (void)windowDidResize;

@end
