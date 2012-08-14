//
//  EDGraphView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDWorksheetElementView.h"
@class EDGraph;

@interface EDGraphView : EDWorksheetElementView{
    @private
    NSPoint                 savedFrameLocation;
    NSPoint                 lastDragLocation;
    NSPoint                 lastCursorLocation;
    NSNotificationCenter    *_nc;
}
//@property (nonatomic, strong) EDGraph *graph;
@property (nonatomic, assign) EDGraph *graph;

- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph;
@end
