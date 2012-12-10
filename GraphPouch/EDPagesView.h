//
//  EDPagesView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/3/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPage.h"

@interface EDPagesView : NSView {
    BOOL _highlighted;
    NSPasteboard *_pb;
    EDPage *_startDragPageData;
    int _highlightedDragSection;
    NSManagedObjectContext *_context;
}

- (void)postInitialize:(NSManagedObjectContext *)context;
- (void)setPageViewStartDragInfo:(EDPage *)pageData;
@end
