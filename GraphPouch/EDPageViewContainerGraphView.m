//
//  EDPageViewContainerGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDEquation.h"
#import "EDGraph.h"
#import "EDGraphView.h"
#import "EDPageViewContainerGraphView.h"
#import "EDParser.h"
#import "NSColor+Utilities.h"

@interface EDPageViewContainerGraphView()
- (NSMutableDictionary *)calculateGraphOrigin:(EDGraph *)graph height:(float)graphHeight width:(float)graphWidth xRatio:(float)xRatio yRatio:(float)yRatio;
- (NSMutableDictionary *)calculateGridIncrement:(float)maxValue minValue:(float)minValue originRatio:(float)ratio length:(float)length scale:(int)scale;
- (void)drawEquation:(EDEquation *)equation verticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo width:(float)graphWidth height:(float)graphHeight graph:(EDGraph *)graph xRatio:(float)xRatio yRatio:(float)yRatio;
- (void)drawGraph;
- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo width:(float)graphWidth height:(float)graphHeight graph:(EDGraph *)graph;
@end

@implementation EDPageViewContainerGraphView

- (id)initWithFrame:(NSRect)frame graph:(EDGraph *)graph context:(NSManagedObjectContext *)context
{
    self = [super initWithFrame:frame];
    if (self) {
        _graph = graph;
        _context = context;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawGraph];
}

- (void)drawGraph{
    //NSArray *graphs = [EDCoreDataUtility getGraphsForPage:_page context:_context];
    //NSArray *graphs = [[_page graphs] allObjects];
    float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
    float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
    float graphWidth, graphHeight;
    NSBezierPath *path;
    NSDictionary *horizontalResults, *verticalResults;
    NSDictionary *originInfo;
    [[NSColor colorWithHexColorString:EDGraphBorderColor] setStroke];
    
    // for each of the graphs draw them
    //for (EDGraph *graph in graphs){
        // draw graph in that position
        graphWidth = xRatio * ([_graph elementWidth] - [EDGraphView graphMargin] * 2);
        graphHeight = yRatio * ([_graph elementHeight] - [EDGraphView graphMargin] * 2);
        originInfo = [self calculateGraphOrigin:_graph height:graphHeight width:graphWidth xRatio:xRatio yRatio:yRatio];
        horizontalResults = [self calculateGridIncrement:[[_graph maxValueX] floatValue] minValue:[[_graph minValueX] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioHorizontal] floatValue] length:graphWidth scale:[[_graph scaleX] intValue]];
        verticalResults = [self calculateGridIncrement:[[_graph maxValueY] floatValue] minValue:[[_graph minValueY] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioVertical] floatValue] length:graphHeight scale:[[_graph scaleY] intValue]];
        
        // draw border
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(xRatio * ([EDGraphView graphMargin] + [_graph locationX]),
                                                           yRatio * ([_graph locationY] + [EDGraphView graphMargin]),
                                                           graphWidth,
                                                           graphHeight)];
        [path setLineWidth:EDPageViewGraphBorderLineWidth];
        [path stroke];
        
        // page view is abstract so we only draw grid and equation
        // draw grid
        if ([_graph hasGridLines]) {
            [self drawVerticalGrid:verticalResults horizontalGrid:horizontalResults origin:originInfo width:graphWidth height:graphHeight graph:_graph];
        }
        
        // draw equations
        for (EDEquation *equation in [_graph equations]){
            [self drawEquation:equation verticalGrid:verticalResults horizontalGrid:horizontalResults origin:originInfo width:graphWidth height:graphHeight graph:_graph xRatio:xRatio yRatio:yRatio];
        }
    //}
}

- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo width:(float)graphWidth height:(float)graphHeight graph:(EDGraph *)graph{
    NSBezierPath *path = [NSBezierPath bezierPath];
    int numGridLines = [[gridInfoVertical objectForKey:EDKeyNumberGridLinesPositive] intValue];
    float distanceIncrement = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float originPosVertical = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originPosHorizontal = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
    float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
    
    // set stroke
    [[NSColor colorWithHexColorString:EDGridColor alpha:EDGridAlpha] setStroke];
    [NSBezierPath setDefaultLineWidth:0.3];
    // draw positive horizontal lines starting from origin
    for (int i=0; i<=numGridLines; i++) {
        // no need to draw all of the lines
        if (i % EDPageViewGraphBorderDrawMultiplier != 0)
            continue;
            
        [path moveToPoint:NSMakePoint(xRatio * ([EDGraphView graphMargin]+[graph locationX]), ([EDGraphView graphMargin]+[graph locationY])*yRatio+originPosVertical - i*distanceIncrement)];
        [path lineToPoint:NSMakePoint(xRatio * ([EDGraphView graphMargin]+[graph locationX]) + graphWidth, ([EDGraphView graphMargin]+[graph locationY])*yRatio+originPosVertical - i*distanceIncrement)];
    }
    
     // draw negative horizontal lines starting from origin
    numGridLines = abs([[gridInfoVertical objectForKey:EDKeyNumberGridLinesNegative] intValue]);
    for (int i=0; i<=numGridLines; i++) {
        // no need to draw all of the lines
        if (i % EDPageViewGraphBorderDrawMultiplier != 0)
            continue;
            
        [path moveToPoint:NSMakePoint(xRatio * ([EDGraphView graphMargin]+[graph locationX]), ([EDGraphView graphMargin]+[graph locationY])*yRatio+originPosVertical + i*distanceIncrement)];
        [path lineToPoint:NSMakePoint(xRatio * ([EDGraphView graphMargin]+[graph locationX]) + graphWidth, ([EDGraphView graphMargin]+[graph locationY])*yRatio+originPosVertical + i*distanceIncrement)];
    }
    
     // grid lines multiplied by 2 because the calculation only covers half the axis
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesPositive] intValue];
    distanceIncrement = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    
    // draw positive vertical lines
    for (int i=0; i<=numGridLines; i++) {
        // no need to draw all of the lines
        if (i % EDPageViewGraphBorderDrawMultiplier != 0)
            continue;
            
        [path moveToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement + xRatio * ([EDGraphView graphMargin]+[graph locationX]), ([EDGraphView graphMargin]+[graph locationY])*yRatio)];
        [path lineToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement + xRatio * ([EDGraphView graphMargin]+[graph locationX]), ([EDGraphView graphMargin]+[graph locationY])*yRatio+graphHeight)];
    }
    
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesNegative] intValue];
    // draw negative vertical lines
    for (int i=0; i<=numGridLines; i++) {
        // no need to draw all of the lines
        if (i % EDPageViewGraphBorderDrawMultiplier != 0)
            continue;
            
        [path moveToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement + xRatio * ([EDGraphView graphMargin]+[graph locationX]), ([EDGraphView graphMargin]+[graph locationY])*yRatio)];
        [path lineToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement + xRatio * ([EDGraphView graphMargin]+[graph locationX]), ([EDGraphView graphMargin]+[graph locationY])*yRatio+graphHeight)];
    }
    [path stroke];
}

- (void)drawEquation:(EDEquation *)equation verticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo width:(float)graphWidth height:(float)graphHeight graph:(EDGraph *)graph xRatio:(float)xRatio yRatio:(float)yRatio{
    // draw equation
    BOOL firstPointDrawnForEquation = true;
    NSError *error;
    NSBezierPath *path = [NSBezierPath bezierPath];
    float diffX, marginDiff, ratioHorizontal, ratioVertical, valueX, valueY, positionVertical;
    
    // set origin points
    //float originVerticalPosition = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue] - [EDGraphView graphMargin];
    //float originHorizontalPosition = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue] - [EDGraphView graphMargin];
    float originVerticalPosition = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originHorizontalPosition = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    
     // ratio positive/negative vertical
    float ratioYPositive, ratioYNegative;
    ratioYPositive = [[graph maxValueY] floatValue]/([[graph maxValueY] floatValue] + fabsf([[graph minValueY] floatValue]));
    ratioYNegative = 1 - ratioYPositive;
    
     // set stroke
    [[NSColor blackColor] setStroke];
    
    //int endInt = (int)[self frame].size.width * EDGraphDependentVariableIncrement;
    int endInt = (int)graphWidth * EDGraphDependentVariableIncrement;
    float i;
    for (int j=0; j<endInt; j++){
        i = j/EDGraphDependentVariableIncrement;
        //NSLog(@"converted j:%f", j/100.0);
        diffX = i - originHorizontalPosition;
        
        // based on position find x
        if (diffX < 0){
            // x is negative
            ratioHorizontal = -1 * diffX/originHorizontalPosition;
            valueX = ratioHorizontal * [[graph minValueX] floatValue];
        }
        else if (diffX == 0){
            valueX = 0;
        }
        else{
            // x is positive
            marginDiff = graphWidth - originHorizontalPosition;
            ratioHorizontal = diffX/marginDiff;
            valueX = ratioHorizontal * [[graph maxValueX] floatValue];
        }
        valueY = [EDParser calculate:[[equation tokens] array] error:&error context:_context varValue:valueX];
        
        // if y is greater than max or less than min than break from loop
        if ((valueY > [[graph maxValueY] floatValue]) || (valueY < [[graph minValueY] floatValue])){
            firstPointDrawnForEquation = true;
            continue;
        }
     
        // based on value find y position
        if (error){
            // we received an error an cannot calculate this value
            // do nothing
        }
        
        if (valueY < 0){
            // y is negative
            ratioVertical = valueY/[[graph minValueY] floatValue];
            positionVertical = originVerticalPosition + ratioVertical * (graphHeight * ratioYNegative);
        }
        else if (valueY == 0){
            positionVertical = originVerticalPosition;
        }
        else{
            // y is positive
            ratioVertical = valueY/[[graph maxValueY] floatValue];
            //positionVertical = originVerticalPosition - ratioVertical * ([self frame].size.height * ratioYPositive);
            positionVertical = originVerticalPosition - ratioVertical * (graphHeight * ratioYPositive);
        }
        
        // must add margin
        positionVertical = ([graph locationY] + [EDGraphView graphMargin]) * yRatio + positionVertical;
        
        if (firstPointDrawnForEquation) {
            [path moveToPoint:NSMakePoint(i + xRatio * ([EDGraphView graphMargin] + [graph locationX]), positionVertical)];
            firstPointDrawnForEquation = false;
        }
        else if (error){
            // reset
            error = nil;
            
            // set variable so that equation will not draw to next point
            firstPointDrawnForEquation = true;
        }
        else {
            [path lineToPoint:NSMakePoint(i + xRatio * ([EDGraphView graphMargin] + [graph locationX]), positionVertical)];
        }
    }

    [path stroke];
}

- (NSMutableDictionary *)calculateGridIncrement:(float)maxValue minValue:(float)minValue originRatio:(float)ratio length:(float)length scale:(int)scale{
    // start by default with one grid line per unit
    float distanceIncrement, maxAxisValue, lengthPositive, lengthNegative, referenceLength, numGridLinesPositive, numGridLinesNegative;
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
     // determine how to divide lengths based on the ratio
    lengthPositive = ((ratio + 1)/2) * length;
    lengthNegative = length - lengthPositive;
    
    // ratio defines which side is going to define the increment
    if (ratio>0){
        referenceLength = lengthPositive;
        maxAxisValue = fabsf(maxValue);
    }
    else{
        referenceLength = lengthNegative;
        maxAxisValue = fabsf(minValue);
    }
    
    distanceIncrement = referenceLength/(maxAxisValue/(float)scale);
    numGridLinesNegative = fabsf(minValue)/(float)scale;
    numGridLinesPositive = maxValue/(float)scale;
    
    [results setObject:[[NSNumber alloc] initWithFloat:distanceIncrement] forKey:EDKeyDistanceIncrement];
    [results setObject:[[NSNumber alloc] initWithInt:scale] forKey:EDKeyGridFactor];
    [results setObject:[[NSNumber alloc] initWithFloat:numGridLinesNegative] forKey:EDKeyNumberGridLinesNegative];
    [results setObject:[[NSNumber alloc] initWithFloat:numGridLinesPositive] forKey:EDKeyNumberGridLinesPositive];
    return results;
}

- (NSMutableDictionary *)calculateGraphOrigin:(EDGraph *)graph height:(float)graphHeight width:(float)graphWidth xRatio:(float)xRatio yRatio:(float)yRatio{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    int absDistanceHoriz = abs([[graph minValueX] intValue]) + abs([[graph maxValueX] intValue]);
    int absDistanceVertical = abs([[graph minValueX]intValue]) + abs([[graph maxValueY] intValue]);
    float ratioHoriz = ([[graph minValueX] floatValue] + [[graph maxValueX] floatValue])/absDistanceHoriz;
    float ratioVertical = ([[graph minValueY] floatValue]+ [[graph maxValueY] floatValue])/absDistanceVertical;
    float originVerticalPosition = graphHeight/2 + (ratioVertical * graphHeight/2);
    float originHorizontalPosition = graphWidth/2 - (ratioHoriz * graphWidth/2);
    [results setValue:[NSNumber numberWithFloat:ratioHoriz] forKey:EDKeyRatioHorizontal];
    [results setValue:[NSNumber numberWithFloat:ratioVertical] forKey:EDKeyRatioVertical];
    [results setValue:[NSNumber numberWithFloat:originHorizontalPosition] forKey:EDKeyOriginPositionHorizontal];
    [results setValue:[NSNumber numberWithFloat:originVerticalPosition] forKey:EDKeyOriginPositionVertical];
    return results;
}
@end
