//
//  EDGraphView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Graph;

@interface EDGraphView : NSView{
    __weak Graph *graph;
    NSPoint lastDragLocation;
    
    @private
    NSPoint lastLocation;
    BOOL selected;
}
@property NSString *viewID;

+ (NSString *)generateID;
- (id)initWithFrame:(NSRect)frame graphModel:(Graph *)myGraph;
@end
