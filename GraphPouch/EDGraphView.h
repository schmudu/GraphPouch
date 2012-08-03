//
//  EDGraphView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDWorksheetElementView.h"
@class Graph;

@interface EDGraphView : EDWorksheetElementView{
    @private
    NSPoint                 savedFrameLocation;
    NSPoint                 lastDragLocation;
    NSPoint                 lastCursorLocation;
}
@property (nonatomic, assign) Graph *graph;

- (id)initWithFrame:(NSRect)frame graphModel:(Graph *)myGraph;
@end
