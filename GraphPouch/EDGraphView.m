//
//  EDGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//
//  The graph view has a width of [self frame] - (2 * (EDGraphMargin + EDCoordinateArrowWidth + EDGraphInnerMargin))
//  [self frame] is the width of the frame of the view
//  EDGraphMargin defines the space in which labels can be drawn next to the coordinate axes
//  EDCoordinateArrowWidth defines the width of the arrow that could potentially be drawn on the very edge of the graph

#import "NS(Attributed)String+Geometrics.h"
#import "EDCoreDataUtility.h"
#import "EDGraphView.h"
#import "EDElement.h"
#import "NSManagedObject+Attributes.h"
#import "NSObject+Document.h"
#import "EDGraph.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"
#import "EDPoint.h"

@interface EDGraphView()
- (float)graphHeight;
- (float)graphWidth;
- (float)graphMargin;
- (float)height;
- (float)width;
- (float)margin;
- (NSArray *)getLowestFactors:(int)number;
- (NSMutableDictionary *)calculateGridIncrement:(float)maxValue minValue:(float)minValue originRatio:(float)ratio length:(float)length;
- (NSMutableDictionary *)calculateGraphOrigin;
- (void)drawCoordinateAxes:(NSDictionary *)originInfo;
- (void)drawPoints:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
- (void)drawPointLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
- (void)drawTickMarks:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
- (void)drawLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo;
@end

@implementation EDGraphView

- (BOOL)isFlipped{
    return TRUE;
}

- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph{
    self = [super initWithFrame:frame];
    if (self){
        _context = [myGraph managedObjectContext];
        _labels = [[NSMutableArray alloc] init];
        
        // set model info
        [self setDataObj:myGraph];
        
        // listen
        _nc = [NSNotificationCenter defaultCenter];
        [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    return self;
}

- (void) dealloc{
    NSManagedObjectContext *context = [self currentContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];
}

- (float)graphMargin{
    // defines margin where graph is actually drawn
    return EDGraphMargin + EDCoordinateArrowWidth + EDCoordinateArrowLength + EDGraphInnerMargin;
    //return EDGraphMargin + EDCoordinateArrowLength + EDGraphInnerMargin;
}

- (float)margin{
    return EDGraphMargin + EDCoordinateArrowWidth;
}

- (float)graphHeight{
    // defines height of graph that doesn't touch the arrows
    return [self height] - 2 * EDCoordinateArrowLength - 2 * EDGraphInnerMargin - 2 * EDCoordinateArrowWidth; 
    //return [self height] - 2 * EDCoordinateArrowLength - 2 * EDGraphInnerMargin;
}

- (float)graphWidth{
    // defines width of graph that doesn't touch the arrows
    return [self width] - 2 * EDCoordinateArrowLength - 2 * EDGraphInnerMargin - 2 * EDCoordinateArrowWidth; 
    //return [self width] - 2 * EDCoordinateArrowLength - 2 * EDGraphInnerMargin;
}

- (float)height{
    return [self frame].size.height - 2 * [self margin];
}

- (float)width{
    return [self frame].size.width - 2 * [self margin];
}

- (void)onContextChanged:(NSNotification *)note{
    // this enables undo method to work
    NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    
    BOOL hasChanged = FALSE;
    int i = 0;
    NSManagedObject *element;
    
    // search through updated array and see if this element has changed
    while ((i<[updatedArray count]) && (!hasChanged)){    
        element = [updatedArray objectAtIndex:i];
        // if data object changed or any of the points, update graph
        if ((element == [self dataObj]) || ([[[self dataObj] points] containsObject:element])) {
            hasChanged = TRUE;
            [self updateDisplayBasedOnContext];
        }
        i++;
    }
}

- (void)updateDisplayBasedOnContext{
    // this is called whenever the context for this object changes
    [super updateDisplayBasedOnContext];
 
    [self removeLabels];
    [self drawLabelAttributes];
}
    
- (void)drawRect:(NSRect)dirtyRect
{
    NSDictionary *originInfo = [self calculateGraphOrigin];
    NSDictionary *horizontalResults = [self calculateGridIncrement:[[[self dataObj] maxValueX] floatValue] minValue:[[[self dataObj] minValueX] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioHorizontal] floatValue] length:[self graphWidth]];
    NSDictionary *verticalResults = [self calculateGridIncrement:[[[self dataObj] maxValueY] floatValue] minValue:[[[self dataObj] minValueY] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioVertical] floatValue] length:[self graphHeight]];
    
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
    
    // color background
    if ([[self dataObj] isSelectedElement]){
        [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:EDGraphSelectedBackgroundAlpha] set];
        [NSBezierPath fillRect:[self bounds]];
    }
    
    // draw points
    if ([[(EDGraph *)[self dataObj] points] count]) {
        [self drawPoints:verticalResults horizontal:horizontalResults origin:originInfo];
    }
}

- (void)drawLabelAttributes{
    NSDictionary *originInfo = [self calculateGraphOrigin];
    NSDictionary *horizontalResults = [self calculateGridIncrement:[[[self dataObj] maxValueX] floatValue] minValue:[[[self dataObj] minValueX] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioHorizontal] floatValue] length:[self graphWidth]];
    NSDictionary *verticalResults = [self calculateGridIncrement:[[[self dataObj] maxValueY] floatValue] minValue:[[[self dataObj] minValueY] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioVertical] floatValue] length:[self graphHeight]];
    
    if ([(EDGraph *)[self dataObj] hasLabels]) {
        [self drawLabels:verticalResults horizontal:horizontalResults origin:originInfo];
    }
    
    // draw points
    if ([[(EDGraph *)[self dataObj] points] count]) {
        [self drawPointLabels:verticalResults horizontal:horizontalResults origin:originInfo];
    }
}

- (void)drawCoordinateAxes:(NSDictionary *)originInfo{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float originVerticalPosition = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originHorizontalPosition = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    [[NSColor blackColor] setStroke];
    
    //draw x-axis
    if ([[[self dataObj] minValueX] intValue] == 0){
        [path moveToPoint:NSMakePoint([self graphMargin], originVerticalPosition)];
    }
    else {
        [path moveToPoint:NSMakePoint([self margin], originVerticalPosition)];
    }
    
    if ([[[self dataObj] maxValueX] intValue] == 0){
        [path lineToPoint:NSMakePoint([self graphMargin] + [self graphWidth], originVerticalPosition)];
    }
    else {
        [path lineToPoint:NSMakePoint([self margin] + [self width], originVerticalPosition)];
    }
    
    // draw x-axis arrow negative, unless min == 0
    if ([[[self dataObj] minValueX] intValue] != 0){
        [path moveToPoint:NSMakePoint([self margin] + EDCoordinateArrowLength, originVerticalPosition + EDCoordinateArrowWidth)];
        [path lineToPoint:NSMakePoint([self margin] , originVerticalPosition)];
        [path lineToPoint:NSMakePoint([self margin] + EDCoordinateArrowLength, originVerticalPosition - EDCoordinateArrowWidth)];
    }
    
    // draw x-axis arrow
    if ([[[self dataObj] maxValueX] intValue] != 0){
        [path moveToPoint:NSMakePoint([self width] + [self margin] - EDCoordinateArrowLength, originVerticalPosition + EDCoordinateArrowWidth)];
        [path lineToPoint:NSMakePoint([self width] + [self margin], originVerticalPosition)];
        [path lineToPoint:NSMakePoint([self width] + [self margin] - EDCoordinateArrowLength, originVerticalPosition - EDCoordinateArrowWidth)];
    }
    
    // draw y-axis, start from graph margin if y max is zero
    if ([[[self dataObj] maxValueY] intValue] == 0){
        [path moveToPoint:NSMakePoint(originHorizontalPosition, 0 + [self graphMargin])];
    }
    else {
        [path moveToPoint:NSMakePoint(originHorizontalPosition, 0 + [self margin])];
    }
    
    // draw to the end of y-axis if y min is zero
    if ([[[self dataObj] minValueY] intValue] == 0){
        [path lineToPoint:NSMakePoint(originHorizontalPosition, [self graphHeight] + [self graphMargin])];
    }
    else{
        [path lineToPoint:NSMakePoint(originHorizontalPosition, [self height] + [self margin])];
    }
    
    // draw y-axis arrow
    if ([[[self dataObj] maxValueY] intValue] != 0){
        [path moveToPoint:NSMakePoint(originHorizontalPosition - EDCoordinateArrowWidth, [self margin] + EDCoordinateArrowLength)];
        [path lineToPoint:NSMakePoint(originHorizontalPosition, [self margin])];
        [path lineToPoint:NSMakePoint(originHorizontalPosition + EDCoordinateArrowWidth, [self margin] + EDCoordinateArrowLength)];
    }
    
    // draw y-axis arrow negative
    if ([[[self dataObj] minValueY] intValue] != 0){
        [path moveToPoint:NSMakePoint(originHorizontalPosition - EDCoordinateArrowWidth, [self height] + [self margin] - EDCoordinateArrowLength)];
        [path lineToPoint:NSMakePoint(originHorizontalPosition, [self height] + [self margin])];
        [path lineToPoint:NSMakePoint(originHorizontalPosition + EDCoordinateArrowWidth, [self height] + [self margin] - EDCoordinateArrowLength)];
    }
    
    [path setLineWidth:EDGraphDefaultCoordinateLineWidth];
    [path stroke];
}

- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo{
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSBezierPath *outlinePath = [NSBezierPath bezierPath];
    int numGridLines = [[gridInfoVertical objectForKey:EDKeyNumberGridLinesPositive] intValue];
    float distanceIncrement = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float originPosVertical = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originPosHorizontal = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    
    [[NSColor redColor] setStroke];
    
    // draw top/bottom of grid
    [outlinePath moveToPoint:NSMakePoint([self graphMargin], [self graphMargin])];
    [outlinePath lineToPoint:NSMakePoint([self graphMargin] + [self graphWidth], [self graphMargin])];
    [outlinePath moveToPoint:NSMakePoint([self graphMargin], [self graphMargin] + [self graphHeight])];
    [outlinePath lineToPoint:NSMakePoint([self graphMargin] + [self graphWidth], [self graphMargin] + [self graphHeight])];
    
    
    // draw right/left side of grid
    [outlinePath moveToPoint:NSMakePoint([self graphMargin], [self graphMargin])];
    [outlinePath lineToPoint:NSMakePoint([self graphMargin], [self graphMargin] + [self graphHeight])];
    [outlinePath moveToPoint:NSMakePoint([self graphMargin] + [self graphWidth], [self graphMargin])];
    [outlinePath lineToPoint:NSMakePoint([self graphMargin] + [self graphWidth], [self graphMargin] + [self graphHeight])];
    
    [outlinePath stroke];
    
    // set stroke
    [[NSColor colorWithHexColorString:EDGridColor alpha:EDGridAlpha] setStroke];
    
    // draw positive horizontal lines starting from origin
    for (int i=0; i<=numGridLines; i++) {
        if ([[[self dataObj] minValueX] intValue] == 0){
            [path moveToPoint:NSMakePoint([self graphMargin], originPosVertical - i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([self graphMargin] + [self graphWidth], originPosVertical - i*distanceIncrement)];
        }
        else if ([[[self dataObj] maxValueX] intValue] == 0){
            [path moveToPoint:NSMakePoint([self graphMargin], originPosVertical - i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([self graphMargin] + [self graphWidth], originPosVertical - i*distanceIncrement)];
        }
        else{
            [path moveToPoint:NSMakePoint([self graphMargin], originPosVertical - i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([self graphMargin] + [self graphWidth], originPosVertical - i*distanceIncrement)];
        }
    }
    
    // draw negative horizontal lines starting from origin
    numGridLines = abs([[gridInfoVertical objectForKey:EDKeyNumberGridLinesNegative] intValue]);
    for (int i=1; i<numGridLines; i++) {
        if ([[[self dataObj] minValueX] intValue] == 0){
            [path moveToPoint:NSMakePoint([self graphMargin], originPosVertical + i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([self graphMargin] + [self graphWidth], originPosVertical + i*distanceIncrement)];
        }
        else if ([[[self dataObj] maxValueX] intValue] == 0){
            [path moveToPoint:NSMakePoint([self graphMargin], originPosVertical + i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([self graphMargin] + [self graphWidth], originPosVertical + i*distanceIncrement)];
        }
        else{
            [path moveToPoint:NSMakePoint([self graphMargin], originPosVertical + i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([self graphMargin] + [self graphWidth], originPosVertical + i*distanceIncrement)];
        }
    }
    
    // grid lines multiplied by 2 because the calculation only covers half the axis
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesPositive] intValue];
    distanceIncrement = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    
    // draw positive vertical lines
    //NSLog(@"frame height:%f graph view height:%f graph height:%f margin:%f graphMargin:%f", [self frame].size.height, [self height], [self graphHeight], [self margin], [self graphMargin]);
    for (int i=0; i<=numGridLines; i++) {
        if ([[[self dataObj] minValueY] intValue] == 0){
            [path moveToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [self graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [self graphHeight] + [self graphMargin])];
        }
        else if ([[[self dataObj] maxValueY] intValue] == 0){
            [path moveToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [self graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [self graphHeight] + [self graphMargin])];
        }
        else{
            [path moveToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [self graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [self graphHeight] + [self graphMargin])];
        }
    }
    
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesNegative] intValue];
    // draw negative vertical lines
    for (int i=0; i<=numGridLines; i++) {
        if ([[[self dataObj] minValueY] intValue] == 0){
            [path moveToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [self graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [self graphHeight] + [self graphMargin])];
        }
        else if ([[[self dataObj] maxValueY] intValue] == 0){
            [path moveToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [self graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [self graphHeight] + [self graphMargin])];
        }
        else{
            [path moveToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [self graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [self graphHeight] + [self graphMargin])];
        }
    }
    
    [path stroke];
}

- (void)drawTickMarks:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo{
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    int numGridLines = [[gridInfoVertical objectForKey:EDKeyNumberGridLinesPositive] intValue];
    float distanceIncrement = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float originPosVertical = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originPosHorizontal = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    
    [path setLineWidth:EDGraphDefaultCoordinateLineWidth];
    
    // set stroke
    [[NSColor blackColor] setStroke];
    
    // draw positive tick marks along y-axis
    for (int i=0; i<=numGridLines; i++) {
        [path moveToPoint:NSMakePoint(originPosHorizontal + EDGraphTickLength, originPosVertical - i*distanceIncrement)];
        [path lineToPoint:NSMakePoint(originPosHorizontal - EDGraphTickLength, originPosVertical - i*distanceIncrement)];
    }
    
    numGridLines = [[gridInfoVertical objectForKey:EDKeyNumberGridLinesNegative] intValue];
    
    // draw negative tick marks along y-axis
    for (int i=0; i<=numGridLines; i++) {
        [path moveToPoint:NSMakePoint(originPosHorizontal + EDGraphTickLength, originPosVertical + i*distanceIncrement)];
        [path lineToPoint:NSMakePoint(originPosHorizontal - EDGraphTickLength, originPosVertical + i*distanceIncrement)];
    }
    
    distanceIncrement = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesPositive] intValue];
    
    // draw positive tick marks along x-axis
    for (int i=0; i<=numGridLines; i++) {
        [path moveToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, originPosVertical + EDGraphTickLength)];
        [path lineToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, originPosVertical - EDGraphTickLength)];
    }
    
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesNegative] intValue];
    // draw negative tick marks along x-axis
    for (int i=0; i<=numGridLines; i++) {
        [path moveToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, originPosVertical + EDGraphTickLength)];
        [path lineToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, originPosVertical - EDGraphTickLength)];
    }
    
    [path stroke];
}

- (NSArray *)getLowestFactors:(int)number{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    // only add decimals if number is 1
    if (number == 1) {
        // add decimals (.1, .2, etc)
        for (float i=.1; i<=1; i=i+.1){
            [results addObject:[[NSNumber alloc] initWithFloat:i]];
        }
    }
    
    // add integers
    for (int i=1; i<=(number/2); i++){
        // if mod == 0
        if((number % i) == 0){
            [results addObject:[[NSNumber alloc] initWithInt:i]];
        }
    }
    return results;
}
#pragma mark calculations
- (NSMutableDictionary *)calculateGridIncrement:(float)maxValue minValue:(float)minValue originRatio:(float)ratio length:(float)length{
    // start by default with one grid line per unit
    float distanceIncrement, numGridLines, maxAxisValue, lengthPositive, lengthNegative, referenceLength, numGridLinesPositive, numGridLinesNegative;
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
    
    // get factors
    NSArray *factors = [self getLowestFactors:maxAxisValue];
    
    // check if distance falls within bounds
    for (NSNumber *factor in factors){
        numGridLines = maxAxisValue/[factor floatValue];
        distanceIncrement = referenceLength/numGridLines;
        
        // define number of grid lines
        numGridLinesNegative = fabs(minValue)/[factor floatValue];
        numGridLinesPositive = maxValue/[factor floatValue];
            
        
        // if grid distance falls within the bounds of the thresholds then return that value
        if ((distanceIncrement < EDGridIncrementalMaximum) && (distanceIncrement > EDGridIncrementalMinimum)){
            [results setObject:[[NSNumber alloc] initWithFloat:[factor floatValue]] forKey:EDKeyGridFactor];
            [results setObject:[[NSNumber alloc] initWithFloat:distanceIncrement] forKey:EDKeyDistanceIncrement];
            [results setObject:[[NSNumber alloc] initWithFloat:numGridLinesNegative] forKey:EDKeyNumberGridLinesNegative];
            [results setObject:[[NSNumber alloc] initWithFloat:numGridLinesPositive] forKey:EDKeyNumberGridLinesPositive];
            //NSLog(@"results:%@", results);
            return results;
        }
    }
    numGridLinesNegative = minValue;
    numGridLinesPositive = maxValue;
    
    // by default return grid the size of the maximum value
    [results setObject:[[NSNumber alloc] initWithFloat:(referenceLength/maxValue)] forKey:EDKeyDistanceIncrement];
    [results setObject:[[NSNumber alloc] initWithInt:1] forKey:EDKeyGridFactor];
    [results setObject:[[NSNumber alloc] initWithFloat:numGridLinesNegative] forKey:EDKeyNumberGridLinesNegative];
    [results setObject:[[NSNumber alloc] initWithFloat:numGridLinesPositive] forKey:EDKeyNumberGridLinesPositive];
    return results;
}

- (NSMutableDictionary *)calculateGraphOrigin{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    int absDistanceHoriz = abs([[(EDGraph *)[self dataObj] minValueX] intValue]) + abs([[(EDGraph *)[self dataObj] maxValueX] intValue]);
    int absDistanceVertical = abs([[(EDGraph *)[self dataObj] minValueY] intValue]) + abs([[(EDGraph *)[self dataObj] maxValueY] intValue]);
    float ratioHoriz = ([[(EDGraph *)[self dataObj] minValueX] floatValue] + [[(EDGraph *)[self dataObj] maxValueX] floatValue])/absDistanceHoriz;
    float ratioVertical = ([[(EDGraph *)[self dataObj] minValueY] floatValue]+ [[(EDGraph *)[self dataObj] maxValueY] floatValue])/absDistanceVertical;
    float originVerticalPosition = [self graphHeight]/2 + (ratioVertical * [self graphHeight]/2) + [self graphMargin];
    float originHorizontalPosition = [self graphWidth]/2 - (ratioHoriz * [self graphWidth]/2) + [self graphMargin];
    
    [results setValue:[NSNumber numberWithFloat:ratioHoriz] forKey:EDKeyRatioHorizontal];
    [results setValue:[NSNumber numberWithFloat:ratioVertical] forKey:EDKeyRatioVertical];
    [results setValue:[NSNumber numberWithFloat:originHorizontalPosition] forKey:EDKeyOriginPositionHorizontal];
    [results setValue:[NSNumber numberWithFloat:originVerticalPosition] forKey:EDKeyOriginPositionVertical];
    return results;
}

#pragma mark labels
- (void)drawLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo{
    NSTextField *numberField, *labelField;
    
    // grid lines multiplied by 2 because the calculation only covers half the axis
    int numGridLinesVertical = [[gridInfoVertical objectForKey:EDKeyNumberGridLinesPositive] intValue];
    int numGridLinesHorizontal = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesPositive] intValue];
    float distanceIncrementVertical = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float distanceIncrementHorizontal = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    
    // set origin points
    float originVerticalPosition = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originHorizontalPosition = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    
    // draw y label
    labelField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    [labelField setStringValue:[[NSString alloc] initWithFormat:@"y"]];
    [labelField setBezeled:FALSE];
    [labelField setDrawsBackground:FALSE];
    [labelField setEditable:FALSE];
    [labelField setSelectable:FALSE];
    [labelField setFrameOrigin:NSMakePoint(originHorizontalPosition + EDGraphVerticalLabelHorizontalOffset + EDCoordinateArrowWidth, EDGraphMargin + EDGraphYLabelVerticalOffset)];
    [self addSubview:labelField];
    [_labels addObject:labelField];
    
    // draw x label
    labelField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    [labelField setStringValue:[[NSString alloc] initWithFormat:@"x"]];
    [labelField setBezeled:FALSE];
    [labelField setDrawsBackground:FALSE];
    [labelField setEditable:FALSE];
    [labelField setSelectable:FALSE];
    [labelField setFrameOrigin:NSMakePoint([self frame].size.width + EDGraphHorizontalLabelHorizontalOffset + EDGraphXLabelHorizontalOffset - EDGraphMargin, originVerticalPosition + EDGraphHorizontalLabelVerticalOffset)];
    [self addSubview:labelField];
    [_labels addObject:labelField];
    
    // draw positive x labels
    for (int i=1; i<=numGridLinesHorizontal; i++) {
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 40, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"%d", i * [[gridInfoHorizontal objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
    
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint(originHorizontalPosition + (distanceIncrementHorizontal * i + EDGraphHorizontalLabelHorizontalOffset), originVerticalPosition + EDGraphHorizontalLabelVerticalOffset)];
        
        // add to list
        [_labels addObject:numberField];
    }
    
    // draw negative x labels
    numGridLinesHorizontal = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesNegative] intValue];
    for (int i=1; i<=numGridLinesHorizontal; i++) {
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 40, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"-%d", i * [[gridInfoHorizontal objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
    
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint(originHorizontalPosition - (distanceIncrementHorizontal * i - EDGraphHorizontalLabelHorizontalOffset + EDGraphHorizontalLabelHorizontalNegativeOffset), originVerticalPosition + EDGraphHorizontalLabelVerticalOffset)];
        
        // add to list
        [_labels addObject:numberField];
    }
    
    // draw positive y labels
    for (int i=1; i<=numGridLinesVertical; i++) {
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 40, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"%d", i * [[gridInfoVertical objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
    
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint(originHorizontalPosition + EDGraphVerticalLabelHorizontalOffset, originVerticalPosition - (distanceIncrementVertical * i + EDGraphVerticalLabelVerticalOffset))];
        
        // add to list
        [_labels addObject:numberField];
    }
    
    // draw negative y labels
    numGridLinesVertical = [[gridInfoVertical objectForKey:EDKeyNumberGridLinesNegative] intValue];
    for (int i=1; i<=numGridLinesVertical; i++) {
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 40, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"-%d", i * [[gridInfoVertical objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
    
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint(originHorizontalPosition + EDGraphVerticalLabelHorizontalOffset, originVerticalPosition + (distanceIncrementVertical * i - EDGraphVerticalLabelVerticalOffset))];
        
        // add to list
        [_labels addObject:numberField];
    }
    
}

- (void)removeLabels{
    // remove all labels from view
    for (NSTextField *numberField in _labels){
        [numberField removeFromSuperview];
    }
    
}

- (void)drawPoints:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo{
    float distanceIncrementVertical = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float distanceIncrementHorizontal = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    //float originX, originY;
    
    // set origin points
    float originVerticalPosition = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originHorizontalPosition = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    
    // set point color
    [[NSColor blackColor] setFill];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    for (EDPoint *point in [(EDGraph *)[self dataObj] points]) {
        if ([point isVisible]) {
            // draw point
            path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(originHorizontalPosition + ([point locationX]/[[gridInfoHorizontal objectForKey:EDKeyGridFactor] floatValue]) * distanceIncrementHorizontal - EDGraphPointDiameter/2,originVerticalPosition - ([point locationY]/[[gridInfoVertical objectForKey:EDKeyGridFactor] floatValue]) * distanceIncrementVertical - EDGraphPointDiameter/2, EDGraphPointDiameter, EDGraphPointDiameter)];
            [path fill]; 
        }
    }
}

- (void)drawPointLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo{
    NSTextField *pointLabel;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    float distanceIncrementVertical = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float distanceIncrementHorizontal = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    float horizontalOffset, labelHeight, labelWidth, pointLocX, pointLocY;
    
    // set origin points
    float originY = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originX = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    
    // set point color
    [[NSColor blackColor] setFill];
    
    // set label constants
    [labelFormatter setMaximumFractionDigits:2];
    [labelFormatter setMinimumFractionDigits:0];
    [labelFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    for (EDPoint *point in [(EDGraph *)[self dataObj] points]) {
        if ([point isVisible]) {
            // draw point
            if ([point showLabel]){
                // create label
                NSString *labelString = [[NSString alloc] initWithFormat:@"(%@,%@)", [labelFormatter stringFromNumber:[NSNumber numberWithFloat:[point locationX]]], [labelFormatter stringFromNumber:[NSNumber numberWithFloat:[point locationY]]]];
                pointLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, EDGraphPointLabelWidth, EDGraphPointLabelHeight)];
                labelWidth = [labelString widthForHeight:[pointLabel frame].size.height attributes:nil];
                labelHeight = [labelString heightForWidth:labelWidth attributes:nil];
                
                // configure horizontal offset, based off dynamic text width
                if ([point locationX] > 0) 
                    horizontalOffset = EDGraphPointLabelHorizontalOffset;
                else 
                    horizontalOffset = -1 * (EDGraphPointLabelHorizontalOffset + labelWidth);
                
                [pointLabel setStringValue:labelString];
                [pointLabel setBezeled:FALSE];
                [pointLabel setDrawsBackground:FALSE];
                [pointLabel setEditable:FALSE];
                [pointLabel setSelectable:FALSE];
                [self addSubview:pointLabel];
                
                // position it
                pointLocX = ([point locationX]/[[gridInfoHorizontal objectForKey:EDKeyGridFactor] floatValue]) * distanceIncrementHorizontal;
                pointLocY = ([point locationY]/[[gridInfoVertical objectForKey:EDKeyGridFactor] floatValue]) * distanceIncrementVertical;
                [pointLabel setFrameOrigin:NSMakePoint(originX + pointLocX + horizontalOffset,originY - pointLocY - EDGraphPointDiameter + EDGraphPointLabelVerticalOffset)];
                [_labels addObject:pointLabel];
            }
        }
    }
    [self setNeedsDisplayInRect:[self frame]];
}
@end