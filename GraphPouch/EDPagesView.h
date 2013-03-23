//
//  EDPagesView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/3/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPage.h"
#import "EDPagesViewSelectionView.h"

@interface EDPagesView : NSView {
    BOOL _highlighted;
    NSPasteboard *_pb;
    EDPage *_startDragPageData;
    int _highlightedDragSection;
    NSManagedObjectContext *_context;
    NSPoint _mousePointDown;
    NSPoint _mousePointDrag;
    EDPagesViewSelectionView *_selectionView;
}

- (void)postInitialize:(NSManagedObjectContext *)context;
- (void)setPageViewStartDragInfo:(EDPage *)pageData;
- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)deselectAll:(id)sender;
@end
