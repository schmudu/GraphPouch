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

@interface EDGraphView : EDWorksheetElementView {
    BOOL _equationsAlreadyDrawn;  // because mouseUp events are not always fired (mouseDown gobbles them up) we need to keep track of whether or not we've drawn the equations
    NSMutableArray *_labels;
    NSMutableArray *_equations;
    NSMutableArray *_points;
    BOOL _drawSelection;
    NSImageView *_viewCoordinate;
    NSImageView *_viewTickMarks;
    NSImageView *_viewGrid;
}

- (NSMutableDictionary *)calculateGridIncrement:(float)maxValue minValue:(float)minValue originRatio:(float)ratio length:(float)length scale:(int)scale;
- (NSMutableDictionary *)calculateGraphOrigin;
- (void)drawCoordinateAxes:(NSDictionary *)originInfo drawAsImage:(BOOL)drawAsImage;
- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo drawAsImage:(BOOL)drawAsImage;
- (void)drawTickMarks:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo  drawAsImage:(BOOL)drawAsImage;
- (void)drawLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
- (void)drawEquations:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
- (void)drawPointsWithLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
- (float)graphHeight;
- (float)graphWidth;
- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph drawSelection:(BOOL)drawSelection;
+ (float)graphMargin;
+ (float)margin;

@end
