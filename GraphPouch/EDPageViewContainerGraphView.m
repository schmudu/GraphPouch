//
//  EDPageViewContainerGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDGraph.h"
#import "EDGraphView.h"
#import "EDPageViewContainerGraphView.h"

@implementation EDPageViewContainerGraphView

- (id)initWithFrame:(NSRect)frame graph:(EDGraph *)graph context:(NSManagedObjectContext *)context
{
    self = [super initWithFrame:frame];
    if (self) {
        _graph = graph;
        _context = context;
        
        float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
        float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
        
        EDGraphView *graphView = [[EDGraphView alloc] initWithFrame:NSMakeRect(0, 0, [_graph elementWidth], [_graph elementHeight]) graphModel:_graph drawSelection:TRUE];
        
        // draw graph attributes on thumbnail
        [graphView drawElementAttributes];
        
        // scale image to page view container
        NSRect thumbnailRect = NSMakeRect(0, 0, [_graph elementWidth] * xRatio, [_graph elementHeight] * yRatio);
        NSImage *expressionImage = [[NSImage alloc] initWithData:[graphView dataWithPDFInsideRect:[graphView frame]]];
        NSImageView *imageViewExpression = [[NSImageView alloc] initWithFrame:thumbnailRect];
        [imageViewExpression setImageScaling:NSScaleProportionally];
        [imageViewExpression setImage:expressionImage];
        
        // add expression view to stage
        [self addSubview:imageViewExpression];
        
        // position it
        [self setFrameOrigin:NSMakePoint([_graph locationX] * xRatio, [_graph locationY] * yRatio)];
    }
    
    return self;
}

- (EDGraph *)graph{
    return _graph;
}

- (BOOL)isFlipped{
    return TRUE;
}
@end
