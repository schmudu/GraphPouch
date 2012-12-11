//
//  EDPageView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/3/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPage.h"

@interface EDPageView : NSView <NSPasteboardWriting, NSPasteboardReading, NSCoding>{
    EDPage *_dataObj;
    NSEvent *_mouseDownEvent;
    NSPasteboard *_pb;
    BOOL _highlighted;
    NSManagedObjectContext *_context;
}
- (EDPage *)dataObj;
- (void)setDataObj:(EDPage *)pageObj;
- (void)deselectPage;
@end
