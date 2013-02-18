//
//  EDGraphViewPrint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDGraph.h"
#import "EDGraphView.h"
#import "EDGraphViewPrint.h"

@implementation EDGraphViewPrint

- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph{
    self = [super initWithFrame:frame graphModel:myGraph];
    
    if (self){
        // do some other printing stuff
        [self drawElementAttributes];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect{
    // override and remove drawing background
    NSDictionary *originInfo = [self calculateGraphOrigin];
    NSDictionary *horizontalResults = [self calculateGridIncrement:[[[self dataObj] maxValueX] floatValue] minValue:[[[self dataObj] minValueX] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioHorizontal] floatValue] length:[self graphWidth] scale:[[[self dataObj] scaleX] intValue]];
    NSDictionary *verticalResults = [self calculateGridIncrement:[[[self dataObj] maxValueY] floatValue] minValue:[[[self dataObj] minValueY] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioVertical] floatValue] length:[self graphHeight] scale:[[[self dataObj] scaleY] intValue]];
    
    // stroke grid
    if ([(EDGraph *)[self dataObj] hasGridLines]) {
        [self drawVerticalGrid:verticalResults horizontalGrid:horizontalResults origin:originInfo];
    }
    
     if ([(EDGraph *)[self dataObj] hasTickMarks]) {
        [self drawTickMarks:verticalResults horizontal:horizontalResults origin:originInfo];
    }
    
    // stroke coordinate axes
    if ([(EDGraph *)[self dataObj] hasCoordinateAxes]) {
        [self drawCoordinateAxes:originInfo];
    }
}
@end
