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
    NSMutableArray *_labels;
    NSMutableArray *_equations;
    NSMutableArray *_points;
}

- (NSMutableDictionary *)calculateGridIncrement:(float)maxValue minValue:(float)minValue originRatio:(float)ratio length:(float)length scale:(int)scale;
- (NSMutableDictionary *)calculateGraphOrigin;
- (void)drawCoordinateAxes:(NSDictionary *)originInfo;
- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
- (void)drawTickMarks:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
- (void)drawLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
- (float)graphHeight;
- (float)graphWidth;
- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph;
+ (float)graphMargin;
+ (float)margin;

@end
