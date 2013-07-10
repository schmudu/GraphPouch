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
#import "EDConstants.h"
#import "EDCoreDataUtility.h"
#import "EDElement.h"
#import "EDEquation.h"
#import "EDEquationCacheView.h"
#import "EDEquationView.h"
#import "EDExpression.h"
#import "EDGraphView.h"
#import "EDGraph.h"
#import "EDParser.h"
#import "EDPoint.h"
#import "EDPointView.h"
#import "EDWorksheetView.h"
#import "NS(Attributed)String+Geometrics.h"
#import "NSColor+Utilities.h"
#import "NSManagedObject+Attributes.h"
#import "NSObject+Document.h"

@interface EDGraphView()
- (float)height;
- (float)width;
- (NSArray *)getLowestFactors:(int)number;
- (void)removeLabels;
- (void)removeEquations;
- (void)removePoints;
- (void)removeCoordinateView;
- (void)removeTickMarksView;
- (void)removeGrid;
- (void)onContextChanged:(NSNotification *)note;
- (void)drawCoordinateAxes:(NSDictionary *)originInfo;
@end

@implementation EDGraphView

- (BOOL)isFlipped{
    return TRUE;
}

//- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph{
- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph drawSelection:(BOOL)drawSelection{
    self = [super initWithFrame:frame];
    if (self){
        _drawSelection = drawSelection;
        _equationsAlreadyDrawn = FALSE;
        _context = [myGraph managedObjectContext];
        _labels = [[NSMutableArray alloc] init];
        _equations = [[NSMutableArray alloc] init];
        _points = [[NSMutableArray alloc] init];
        
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

+ (float)graphMargin{
    // defines margin where graph is actually drawn
    return EDGraphMargin + EDCoordinateArrowWidth + EDCoordinateArrowLength + EDGraphInnerMargin;
}

+ (float)margin{
    return EDGraphMargin + EDCoordinateArrowWidth;
}

- (float)graphHeight{
    // defines height of graph that doesn't touch the arrows
    return [self height] - EDCoordinateArrowLength - 2 * EDGraphInnerMargin - 2 * EDCoordinateArrowWidth;
}

- (float)graphWidth{
    // defines width of graph that doesn't touch the arrows
    return [self width] - EDCoordinateArrowLength - 2 * EDGraphInnerMargin - 2 * EDCoordinateArrowWidth;
}

- (float)height{
    return [self frame].size.height - 2 * [EDGraphView margin];
}

- (float)width{
    return [self frame].size.width - 2 * [EDGraphView margin];
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
        if ((element == [self dataObj]) || ([[[self dataObj] points] containsObject:element])|| ([[[self dataObj] equations] containsObject:element])) {
            hasChanged = TRUE;
            [self updateDisplayBasedOnContext];
        }
        i++;
    }
    
    /*
    for (NSView *view in _equations){
        NSLog(@"context changed view:%@ origin:%@, frame:%@ bounds:%@", view, NSStringFromPoint([view frame].origin), NSStringFromRect([view frame]), NSStringFromRect([view bounds]));
    }*/
}

- (void)updateDisplayBasedOnContext{
    // this is called whenever the context for this object changes
    [super updateDisplayBasedOnContext];
 
    [self removeFeatures];
    [self drawElementAttributes];
    /*
    NSLog(@"==after drawing features: number of equation views:%ld", [_equations count]);
    for (NSView *view in _equations){
        NSLog(@"view:%@ origin:%@, frame:%@ bounds:%@", view, NSStringFromPoint([view frame].origin), NSStringFromRect([view frame]), NSStringFromRect([view bounds]));
    }
    NSLog(@"==end");
     */
}
    
- (void)drawRect:(NSRect)dirtyRect{
    /*
     NSDictionary *originInfo = [self calculateGraphOrigin];
    NSDictionary *horizontalResults = [self calculateGridIncrement:[[[self dataObj] maxValueX] floatValue] minValue:[[[self dataObj] minValueX] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioHorizontal] floatValue] length:[self graphWidth] scale:[[[self dataObj] scaleX] intValue]];
    NSDictionary *verticalResults = [self calculateGridIncrement:[[[self dataObj] maxValueY] floatValue] minValue:[[[self dataObj] minValueY] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioVertical] floatValue] length:[self graphHeight] scale:[[[self dataObj] scaleY] intValue]];
    
    // draw coordinates
    if ([(EDGraph *)[self dataObj] hasCoordinateAxes]) {
        [self drawCoordinateAxes:originInfo];
    }
    
    // tick marks
    if ([(EDGraph *)[self dataObj] hasTickMarks]) {
        [self drawTickMarks:verticalResults horizontal:horizontalResults origin:originInfo];
    }
    
    // grid lines
    if ([(EDGraph *)[self dataObj] hasGridLines]) {
        [self drawVerticalGrid:verticalResults horizontalGrid:horizontalResults origin:originInfo];
    }*/
    
    // color background
    if ((_drawSelection) && ([[self dataObj] isSelectedElement])){
        [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:EDGraphSelectedBackgroundAlpha] set];
        [NSBezierPath fillRect:[self bounds]];
    }
}

- (void)drawElementAttributes{
    NSDictionary *originInfo = [self calculateGraphOrigin];
    NSDictionary *horizontalResults = [self calculateGridIncrement:[[[self dataObj] maxValueX] floatValue] minValue:[[[self dataObj] minValueX] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioHorizontal] floatValue] length:[self graphWidth] scale:[[[self dataObj] scaleX] intValue]];
    NSDictionary *verticalResults = [self calculateGridIncrement:[[[self dataObj] maxValueY] floatValue] minValue:[[[self dataObj] minValueY] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioVertical] floatValue] length:[self graphHeight] scale:[[[self dataObj] scaleY] intValue]];
    
    // draw equations
    if ([[(EDGraph *)[self dataObj] equations] count]) {
        [self drawEquations:verticalResults horizontal:horizontalResults origin:originInfo];
    }
    
    // draw points
    if ([[(EDGraph *)[self dataObj] points] count]) {
        [self drawPointsWithLabels:verticalResults horizontal:horizontalResults origin:originInfo];
    }
    
     // grid lines
    if ([(EDGraph *)[self dataObj] hasGridLines]) {
        [self drawVerticalGrid:verticalResults horizontalGrid:horizontalResults origin:originInfo];
    }
    
    // draw coordinates
    if ([(EDGraph *)[self dataObj] hasCoordinateAxes]) {
        [self drawCoordinateAxes:originInfo];
    }
    
     // tick marks
    if ([(EDGraph *)[self dataObj] hasTickMarks]) {
        [self drawTickMarks:verticalResults horizontal:horizontalResults origin:originInfo];
    }
    
    // draw labels
    if ([(EDGraph *)[self dataObj] hasLabels]) {
        [self drawLabels:verticalResults horizontal:horizontalResults origin:originInfo];
    }
    
    // debug
    /*
    for (NSView *view in _equations){
        NSLog(@"after view:%@ origin:%@, frame:%@ bounds:%@", view, NSStringFromPoint([view frame].origin), NSStringFromRect([view frame]), NSStringFromRect([view bounds]));
    }*/
}

- (void)drawCoordinateAxes:(NSDictionary *)originInfo{
    NSImage *imageCoordinate = [[NSImage alloc] initWithSize:[self frame].size];
    [imageCoordinate lockFocus];
    
    // flip coordinates
    NSAffineTransform* t = [NSAffineTransform transform];
    [t translateXBy:0 yBy:[self frame].size.height];
    [t scaleXBy:1 yBy:-1];
    [t concat];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    float originVerticalPosition = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originHorizontalPosition = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    [[NSColor blackColor] setStroke];
    
    //draw x-axis
    if ([[[self dataObj] minValueX] intValue] == 0){
        [path moveToPoint:NSMakePoint([EDGraphView graphMargin], originVerticalPosition)];
    }
    else {
        [path moveToPoint:NSMakePoint([EDGraphView margin], originVerticalPosition)];
    }
    
    if ([[[self dataObj] maxValueX] intValue] == 0){
        [path lineToPoint:NSMakePoint([EDGraphView graphMargin] + [self graphWidth], originVerticalPosition)];
    }
    else {
        [path lineToPoint:NSMakePoint([EDGraphView margin] + [self width], originVerticalPosition)];
    }
    
    // draw x-axis arrow negative, unless min == 0
    if ([[[self dataObj] minValueX] intValue] != 0){
        [path moveToPoint:NSMakePoint([EDGraphView margin] + EDCoordinateArrowLength, originVerticalPosition + EDCoordinateArrowWidth)];
        [path lineToPoint:NSMakePoint([EDGraphView margin] , originVerticalPosition)];
        [path lineToPoint:NSMakePoint([EDGraphView margin] + EDCoordinateArrowLength, originVerticalPosition - EDCoordinateArrowWidth)];
    }
    
    // draw x-axis arrow
    if ([[[self dataObj] maxValueX] intValue] != 0){
        [path moveToPoint:NSMakePoint([self width] + [EDGraphView margin] - EDCoordinateArrowLength, originVerticalPosition + EDCoordinateArrowWidth)];
        [path lineToPoint:NSMakePoint([self width] + [EDGraphView margin], originVerticalPosition)];
        [path lineToPoint:NSMakePoint([self width] + [EDGraphView margin] - EDCoordinateArrowLength, originVerticalPosition - EDCoordinateArrowWidth)];
    }
    
    // draw y-axis, start from graph margin if y max is zero
    if ([[[self dataObj] maxValueY] intValue] == 0){
        [path moveToPoint:NSMakePoint(originHorizontalPosition, 0 + [EDGraphView graphMargin])];
    }
    else {
        [path moveToPoint:NSMakePoint(originHorizontalPosition, 0 + [EDGraphView margin])];
    }
    
    // draw to the end of y-axis if y min is zero
    if ([[[self dataObj] minValueY] intValue] == 0){
        [path lineToPoint:NSMakePoint(originHorizontalPosition, [self graphHeight] + [EDGraphView graphMargin])];
    }
    else{
        [path lineToPoint:NSMakePoint(originHorizontalPosition, [self height] + [EDGraphView margin])];
    }
    
    // draw y-axis arrow
    if ([[[self dataObj] maxValueY] intValue] != 0){
        [path moveToPoint:NSMakePoint(originHorizontalPosition - EDCoordinateArrowWidth, [EDGraphView margin] + EDCoordinateArrowLength)];
        [path lineToPoint:NSMakePoint(originHorizontalPosition, [EDGraphView margin])];
        [path lineToPoint:NSMakePoint(originHorizontalPosition + EDCoordinateArrowWidth, [EDGraphView margin] + EDCoordinateArrowLength)];
    }
    
    // draw y-axis arrow negative
    if ([[[self dataObj] minValueY] intValue] != 0){
        [path moveToPoint:NSMakePoint(originHorizontalPosition - EDCoordinateArrowWidth, [self height] + [EDGraphView margin] - EDCoordinateArrowLength)];
        [path lineToPoint:NSMakePoint(originHorizontalPosition, [self height] + [EDGraphView margin])];
        [path lineToPoint:NSMakePoint(originHorizontalPosition + EDCoordinateArrowWidth, [self height] + [EDGraphView margin] - EDCoordinateArrowLength)];
    }
    
    [path setLineWidth:EDGraphDefaultCoordinateLineWidth];
    [path stroke];
     [imageCoordinate unlockFocus];
    
    // set image view
    if (_viewCoordinate){
        [_viewCoordinate removeFromSuperview];
        _viewCoordinate = nil;
    }
    
    _viewCoordinate = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height)];
    [_viewCoordinate setImage:imageCoordinate];
    [self addSubview:_viewCoordinate];
}

- (void)removeCoordinateView{
    if (_viewCoordinate)
        [_viewCoordinate removeFromSuperview];
}

- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo{
    NSImage *imageGrid = [[NSImage alloc] initWithSize:[self frame].size];
    [imageGrid lockFocus];
    
    // flip coordinates
    NSAffineTransform* t = [NSAffineTransform transform];
    [t translateXBy:0 yBy:[self frame].size.height];
    [t scaleXBy:1 yBy:-1];
    [t concat];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSBezierPath *outlinePath = [NSBezierPath bezierPath];
    int numGridLines = [[gridInfoVertical objectForKey:EDKeyNumberGridLinesPositive] intValue];
    float distanceIncrement = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float originPosVertical = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originPosHorizontal = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    [[NSColor colorWithHexColorString:EDGridColor alpha:EDGridAlpha] setStroke];
    
    // draw top/bottom of grid
    [outlinePath moveToPoint:NSMakePoint([EDGraphView graphMargin], [EDGraphView graphMargin])];
    [outlinePath lineToPoint:NSMakePoint([EDGraphView graphMargin] + [self graphWidth], [EDGraphView graphMargin])];
    [outlinePath moveToPoint:NSMakePoint([EDGraphView graphMargin], [EDGraphView graphMargin] + [self graphHeight])];
    [outlinePath lineToPoint:NSMakePoint([EDGraphView graphMargin] + [self graphWidth], [EDGraphView graphMargin] + [self graphHeight])];
    
    // draw right/left side of grid
    [outlinePath moveToPoint:NSMakePoint([EDGraphView graphMargin], [EDGraphView graphMargin])];
    [outlinePath lineToPoint:NSMakePoint([EDGraphView graphMargin], [EDGraphView graphMargin] + [self graphHeight])];
    [outlinePath moveToPoint:NSMakePoint([EDGraphView graphMargin] + [self graphWidth], [EDGraphView graphMargin])];
    [outlinePath lineToPoint:NSMakePoint([EDGraphView graphMargin] + [self graphWidth], [EDGraphView graphMargin] + [self graphHeight])];
    
    [outlinePath stroke];
    
    // set stroke
    [[NSColor colorWithHexColorString:EDGridColor alpha:EDGridAlpha] setStroke];
    
    // draw positive horizontal lines starting from origin
    for (int i=0; i<=numGridLines; i++) {
        [path moveToPoint:NSMakePoint([EDGraphView graphMargin], originPosVertical - i*distanceIncrement)];
        [path lineToPoint:NSMakePoint([EDGraphView graphMargin] + [self graphWidth], originPosVertical - i*distanceIncrement)];
    }
    
     // draw negative horizontal lines starting from origin
    numGridLines = abs([[gridInfoVertical objectForKey:EDKeyNumberGridLinesNegative] intValue]);
    for (int i=0; i<=numGridLines; i++) {
        [path moveToPoint:NSMakePoint([EDGraphView graphMargin], originPosVertical + i*distanceIncrement)];
        [path lineToPoint:NSMakePoint([EDGraphView graphMargin] + [self graphWidth], originPosVertical + i*distanceIncrement)];
    }
    
     // grid lines multiplied by 2 because the calculation only covers half the axis
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesPositive] intValue];
    distanceIncrement = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    
    // draw positive vertical lines
    for (int i=0; i<=numGridLines; i++) {
        [path moveToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [EDGraphView graphMargin])];
        [path lineToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [self graphHeight] + [EDGraphView graphMargin])];
    }
    
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesNegative] intValue];
    // draw negative vertical lines
    for (int i=0; i<=numGridLines; i++) {
        [path moveToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [EDGraphView graphMargin])];
        [path lineToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [self graphHeight] + [EDGraphView graphMargin])];
    }
    
    [path stroke];
    [imageGrid unlockFocus];
    
    // set image view
    if (_viewGrid){
        [_viewGrid removeFromSuperview];
        _viewGrid = nil;
    }
    
    _viewGrid = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height)];
    [_viewGrid setImage:imageGrid];
    [self addSubview:_viewGrid];
}

- (void)removeGrid{
    if (_viewGrid)
        [_viewGrid removeFromSuperview];
}

- (void)drawTickMarks:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo{
    NSImage *imageTickMarks = [[NSImage alloc] initWithSize:[self frame].size];
    [imageTickMarks lockFocus];
    
    // flip coordinates
    NSAffineTransform* t = [NSAffineTransform transform];
    [t translateXBy:0 yBy:[self frame].size.height];
    [t scaleXBy:1 yBy:-1];
    [t concat];
    
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
    [imageTickMarks unlockFocus];
    
    // set image view
    if (_viewTickMarks){
        [_viewTickMarks removeFromSuperview];
        _viewTickMarks = nil;
    }
    
    _viewTickMarks = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height)];
    [_viewTickMarks setImage:imageTickMarks];
    [self addSubview:_viewTickMarks];
}

- (void)removeTickMarksView{
    if (_viewTickMarks)
        [_viewTickMarks removeFromSuperview];
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

- (NSMutableDictionary *)calculateGraphOrigin{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    int absDistanceHoriz = abs([[(EDGraph *)[self dataObj] minValueX] intValue]) + abs([[(EDGraph *)[self dataObj] maxValueX] intValue]);
    int absDistanceVertical = abs([[(EDGraph *)[self dataObj] minValueY] intValue]) + abs([[(EDGraph *)[self dataObj] maxValueY] intValue]);
    float ratioHoriz = ([[(EDGraph *)[self dataObj] minValueX] floatValue] + [[(EDGraph *)[self dataObj] maxValueX] floatValue])/absDistanceHoriz;
    float ratioVertical = ([[(EDGraph *)[self dataObj] minValueY] floatValue]+ [[(EDGraph *)[self dataObj] maxValueY] floatValue])/absDistanceVertical;
    float originVerticalPosition = [self graphHeight]/2 + (ratioVertical * [self graphHeight]/2) + [EDGraphView graphMargin];
    float originHorizontalPosition = [self graphWidth]/2 - (ratioHoriz * [self graphWidth]/2) + [EDGraphView graphMargin];
    
    [results setValue:[NSNumber numberWithFloat:ratioHoriz] forKey:EDKeyRatioHorizontal];
    [results setValue:[NSNumber numberWithFloat:ratioVertical] forKey:EDKeyRatioVertical];
    [results setValue:[NSNumber numberWithFloat:originHorizontalPosition] forKey:EDKeyOriginPositionHorizontal];
    [results setValue:[NSNumber numberWithFloat:originVerticalPosition] forKey:EDKeyOriginPositionVertical];
    return results;
}

#pragma mark labels
- (void)drawLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo{
    NSTextField *numberField, *labelField;
    NSFont *defaultFont;
    
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
    
    // resize font
    defaultFont = [NSFont fontWithName:[[labelField font] fontName] size:EDFontDefaultSize];
    [labelField setFont:defaultFont];
    
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
    [labelField setFont:defaultFont];
    [labelField setFrameOrigin:NSMakePoint([self frame].size.width + EDGraphHorizontalLabelHorizontalOffset + EDGraphXLabelHorizontalOffset - EDGraphMargin, originVerticalPosition + EDGraphHorizontalLabelVerticalOffset)];
    [self addSubview:labelField];
    [_labels addObject:labelField];
    
    // draw positive and zero x labels
    for (int i=0; i<=numGridLinesHorizontal; i++) {
        // only draw labels needed
        if (i % [[[self dataObj] labelIntervalX] intValue] != 0)
            continue;
        
        // only draw zero label if min value x = 0 and min value y = 0
        if ((i==0) && ([[(EDGraph *)[self dataObj] minValueY] intValue] != 0))
            continue;
        
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 40, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"%d", i * [[gridInfoHorizontal objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
        [numberField setFont:defaultFont];
        
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint(originHorizontalPosition + (distanceIncrementHorizontal * i + EDGraphHorizontalLabelHorizontalOffset), originVerticalPosition + EDGraphHorizontalLabelVerticalOffset)];
        
        // add to list
        [_labels addObject:numberField];
    }
    
    // draw negative x labels
    numGridLinesHorizontal = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesNegative] intValue];
    for (int i=1; i<=numGridLinesHorizontal; i++) {
        // only draw labels needed
        if (i % [[[self dataObj] labelIntervalX] intValue] != 0)
            continue;
        
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 40, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"-%d", i * [[gridInfoHorizontal objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
        [numberField setFont:defaultFont];
        
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint(originHorizontalPosition - (distanceIncrementHorizontal * i - EDGraphHorizontalLabelHorizontalOffset + EDGraphHorizontalLabelHorizontalNegativeOffset), originVerticalPosition + EDGraphHorizontalLabelVerticalOffset)];
        
        // add to list
        [_labels addObject:numberField];
    }
    
    // draw positive y labels
    for (int i=0; i<=numGridLinesVertical; i++) {
        // only draw labels needed
        if (i % [[[self dataObj] labelIntervalY] intValue] != 0)
            continue;
        
        // only draw zero label if min value x = 0 and min value y = 0
        if ((i==0) && ([[(EDGraph *)[self dataObj] minValueX] intValue] != 0))
            continue;
        
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 40, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"%d", i * [[gridInfoVertical objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
        [numberField setFont:defaultFont];
        
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint(originHorizontalPosition + EDGraphVerticalLabelHorizontalOffset + EDGridAxisYHorizontalOffset - [numberField intrinsicContentSize].width, originVerticalPosition - (distanceIncrementVertical * i + EDGraphVerticalLabelVerticalOffset))];
        
        // add to list
        [_labels addObject:numberField];
    }
    
    // draw negative y labels
    numGridLinesVertical = [[gridInfoVertical objectForKey:EDKeyNumberGridLinesNegative] intValue];
    for (int i=1; i<=numGridLinesVertical; i++) {
        // only draw labels needed
        if (i % [[[self dataObj] labelIntervalY] intValue] != 0)
            continue;
        
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 40, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"-%d", i * [[gridInfoVertical objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
        [numberField setFont:defaultFont];
        
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint(originHorizontalPosition + EDGraphVerticalLabelHorizontalOffset + EDGridAxisYHorizontalOffset - [numberField intrinsicContentSize].width, originVerticalPosition + (distanceIncrementVertical * i - EDGraphVerticalLabelVerticalOffset))];
        
        // add to list
        [_labels addObject:numberField];
    }
    
}

- (void)removeLabels{
    // remove all labels from view
    for (NSTextField *numberField in _labels){
        [numberField removeFromSuperview];
    }
    
    // remove all objects
    [_labels removeAllObjects];
}

- (void)removeEquations{
    // remove all labels from view
    for (NSView *equationView in _equations){
        [equationView removeFromSuperview];
    }
    
    // remove all objects
    [_equations removeAllObjects];
    
    _equationsAlreadyDrawn = FALSE;
}

- (void)removePoints{
    // remove all labels from view
    for (NSView *pointView in _points){
        [pointView removeFromSuperview];
    }
    
    // remove all objects
    [_points removeAllObjects];
}

- (void)drawEquations:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo{
    // if equations already drawn then do nothing
    if (_equationsAlreadyDrawn)
        return;
    
    NSLog(@"drawing equation.");
    EDEquationView *equationView;
    NSImageView *imageView;
    NSImage *equationImage;
    
    // for each graph create a graph view
    for (EDEquation *equation in [[self dataObj] equations]){
        // if not visible then do not draw this equation
        if (![equation isVisible])
            continue;
        
        // THIS CODE IS REALLY SLOW
        // create origin equation view
        equationView = [[EDEquationView alloc] initWithFrame:NSMakeRect(0, 0, [self graphWidth], [self graphHeight]) equation:equation];
        [equationView setGraphOrigin:originInfo verticalInfo:gridInfoVertical horizontalInfo:gridInfoHorizontal graph:(EDGraph *)[self dataObj] context:_context];
        
        // create image
        equationImage = [[NSImage alloc] initWithData:[equationView dataWithPDFInsideRect:[equationView bounds]]];
        
        // set image
        imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, [self graphWidth], [self graphHeight])];
        [imageView setImage:equationImage];
        
        // add to subview
        [self addSubview:imageView];
        
        // set origin
        [imageView setFrameOrigin:NSMakePoint([EDGraphView graphMargin], [EDGraphView graphMargin])];
        [_equations addObject:imageView];
    }
    
    _equationsAlreadyDrawn = TRUE;
}

- (void)drawPointsWithLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo{
    NSTextField *pointLabel;
    NSView *pointView;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    float distanceIncrementVertical = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float distanceIncrementHorizontal = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    float horizontalOffset, labelWidth, pointLocX, pointLocY;
    
    // set origin points
    float originY = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originX = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    
    // set label constants
    [labelFormatter setMaximumFractionDigits:2];
    [labelFormatter setMinimumFractionDigits:0];
    [labelFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    for (EDPoint *point in [(EDGraph *)[self dataObj] points]) {
        if ([point isVisible]) {
            // draw point
            pointView = [[EDPointView alloc] initWithFrame:NSMakeRect(originX + ([point locationX]/[[gridInfoHorizontal objectForKey:EDKeyGridFactor] floatValue]) * distanceIncrementHorizontal - EDGraphPointDiameter/2,originY - ([point locationY]/[[gridInfoVertical objectForKey:EDKeyGridFactor] floatValue]) * distanceIncrementVertical - EDGraphPointDiameter/2, EDGraphPointDiameter, EDGraphPointDiameter)];
            [self addSubview:pointView];
            [_points addObject:pointView];
            
            // draw label
            if ([point showLabel]){
                // create label
                NSString *labelString = [[NSString alloc] initWithFormat:@"(%@,%@)", [labelFormatter stringFromNumber:[NSNumber numberWithFloat:[point locationX]]], [labelFormatter stringFromNumber:[NSNumber numberWithFloat:[point locationY]]]];
                pointLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, EDGraphPointLabelWidth, EDGraphPointLabelHeight)];
                // reset width based on dynamic width
                
                [pointLabel setStringValue:labelString];
                [pointLabel setBezeled:FALSE];
                [pointLabel setDrawsBackground:FALSE];
                [pointLabel setEditable:FALSE];
                [pointLabel setSelectable:FALSE];
                [pointLabel setFrameSize:NSMakeSize([pointLabel intrinsicContentSize].width + EDGraphPointLabelHorizontalOffset, [pointLabel frame].size.height)];
                
                // resize
                NSFont *defaultFont = [NSFont fontWithName:[[pointLabel font] fontName] size:EDFontDefaultSize];
                [pointLabel setFont:defaultFont];
    
                [self addSubview:pointLabel];
                
                labelWidth = [pointLabel intrinsicContentSize].width + EDGraphPointLabelHorizontalOffset;
                
                // configure horizontal offset, based off dynamic text width
                if ([point locationX] > 0) 
                    horizontalOffset = EDGraphPointLabelHorizontalOffset;
                else 
                    horizontalOffset = -1 * (EDGraphPointLabelHorizontalOffset + labelWidth);
                
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

#pragma mark dragging
- (void)removeFeatures{
    // method called to remove performance-heavy elements
    [self removeLabels];
    [self removeEquations];
    [self removePoints];
    [self removeCoordinateView];
    [self removeTickMarksView];
    [self removeGrid];
}


- (void)addFeatures{
    // this method isn't need because when the context changes (e.g. dragged) the model changes and the elements update automatically
    [self drawElementAttributes];
}
@end