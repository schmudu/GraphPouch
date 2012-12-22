//
//  EDGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

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
- (NSArray *)getLowestIntegralFactors:(int)number;
- (NSMutableDictionary *)calculateGridIncrement:(int)maxValue length:(float)length;
- (NSMutableDictionary *)calculateGraphOrigin;
- (void)drawCoordinateAxes;
- (void)drawPoints:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal;
- (void)drawPointLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal;
- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal;
- (void)drawTickMarks:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal;
- (void)drawLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal;
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
    NSDictionary *originResults = [self calculateGraphOrigin];
    NSDictionary *verticalResults = [self calculateGridIncrement:EDGridMaximum length:[self frame].size.height/2];
    NSDictionary *horizontalResults = [self calculateGridIncrement:EDGridMaximum length:[self frame].size.width/2];
    
    // stroke grid
    if ([(EDGraph *)[self dataObj] hasGridLines]) {
        [self drawVerticalGrid:verticalResults horizontalGrid:horizontalResults];
    }
    
    if ([(EDGraph *)[self dataObj] hasTickMarks]) {
        [self drawTickMarks:verticalResults horizontal:horizontalResults];
    }
    
    // stroke coordinate axes
    if ([(EDGraph *)[self dataObj] hasCoordinateAxes]) {
        [self drawCoordinateAxes];
    }
    
    // color background
    if ([[self dataObj] isSelectedElement]){
        [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:EDGraphSelectedBackgroundAlpha] set];
        [NSBezierPath fillRect:[self bounds]];
    }
    
    // draw points
    if ([[(EDGraph *)[self dataObj] points] count]) {
        [self drawPoints:verticalResults horizontal:horizontalResults];
    }
}

- (void)drawLabelAttributes{
    NSDictionary *verticalResults = [self calculateGridIncrement:EDGridMaximum length:[self frame].size.height/2];
    NSDictionary *horizontalResults = [self calculateGridIncrement:EDGridMaximum length:[self frame].size.width/2];
    
    if ([(EDGraph *)[self dataObj] hasLabels]) {
        [self drawLabels:verticalResults horizontal:horizontalResults];
    }
    
    // draw points
    if ([[(EDGraph *)[self dataObj] points] count]) {
        [self drawPointLabels:verticalResults horizontal:horizontalResults];
    }
}

- (void)drawCoordinateAxes{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float height = [self frame].size.height;
    float width = [self frame].size.width;
    [[NSColor blackColor] setStroke];
    
    //draw x-axis
    [path moveToPoint:NSMakePoint(0, height/2)];
    [path lineToPoint:NSMakePoint(width, height/2)];
    
    // draw x-axis arrow negative
    [path moveToPoint:NSMakePoint(0 + EDCoordinateArrowLength, height/2 + EDCoordinateArrowWidth)];
    [path lineToPoint:NSMakePoint(0 , height/2)];
    [path lineToPoint:NSMakePoint(0 + EDCoordinateArrowLength, height/2 - EDCoordinateArrowWidth)];
    
    // draw x-axis arrow
    [path moveToPoint:NSMakePoint(width - EDCoordinateArrowLength, height/2 + EDCoordinateArrowWidth)];
    [path lineToPoint:NSMakePoint(width , height/2)];
    [path lineToPoint:NSMakePoint(width - EDCoordinateArrowLength, height/2 - EDCoordinateArrowWidth)];
    
    // draw y-axis
    [path moveToPoint:NSMakePoint(width/2, 0)];
    [path lineToPoint:NSMakePoint(width/2, height)];
    
    // draw y-axis arrow
    [path moveToPoint:NSMakePoint(width/2 - EDCoordinateArrowWidth, 0 + EDCoordinateArrowLength)];
    [path lineToPoint:NSMakePoint(width/2, 0)];
    [path lineToPoint:NSMakePoint(width/2 + EDCoordinateArrowWidth, 0 + EDCoordinateArrowLength)];
    
    // draw y-axis arrow negative
    [path moveToPoint:NSMakePoint(width/2 - EDCoordinateArrowWidth, height - EDCoordinateArrowLength)];
    [path lineToPoint:NSMakePoint(width/2, height)];
    [path lineToPoint:NSMakePoint(width/2 + EDCoordinateArrowWidth, height - EDCoordinateArrowLength)];
    
    [path setLineWidth:EDGraphDefaultCoordinateLineWidth];
    [path stroke];
}

- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal{
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    // grid lines multiplied by 2 because the calculation only covers half the axis
    int numGridLines = [[gridInfoVertical objectForKey:EDKeyGridLinesCount] intValue]*2;
    float distanceIncrement = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    
    // set stroke
    //[[NSColor grayColor] setStroke];
    [[NSColor colorWithHexColorString:EDGridColor alpha:EDGridAlpha] setStroke];
    
    // draw vertical lines
    for (int i=0; i<=numGridLines; i++) {
        [path moveToPoint:NSMakePoint(0, i*distanceIncrement)];
        [path lineToPoint:NSMakePoint([self frame].size.width, i*distanceIncrement)];
    }
    
    // grid lines multiplied by 2 because the calculation only covers half the axis
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyGridLinesCount] intValue]*2;
    distanceIncrement = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    
    // draw horizontal lines
    for (int i=0; i<=numGridLines; i++) {
        [path moveToPoint:NSMakePoint(i*distanceIncrement, 0)];
        [path lineToPoint:NSMakePoint(i*distanceIncrement, [self frame].size.height)];
    }
    [path stroke];
}

- (void)drawTickMarks:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal{
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:EDGraphDefaultCoordinateLineWidth];
    
    // grid lines multiplied by 2 because the calculation only covers half the axis
    int numGridLines = [[gridInfoVertical objectForKey:EDKeyGridLinesCount] intValue]*2;
    float distanceIncrement = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    
    // set stroke
    [[NSColor blackColor] setStroke];
    
    // draw vertical lines
    for (int i=1; i<numGridLines; i++) {
        [path moveToPoint:NSMakePoint([self frame].size.width/2 - EDGraphTickLength, i*distanceIncrement)];
        [path lineToPoint:NSMakePoint([self frame].size.width/2 + EDGraphTickLength, i*distanceIncrement)];
    }
    
    // grid lines multiplied by 2 because the calculation only covers half the axis
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyGridLinesCount] intValue]*2;
    distanceIncrement = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    
    // draw horizontal lines
    for (int i=1; i<numGridLines; i++) {
        [path moveToPoint:NSMakePoint(i*distanceIncrement, [self frame].size.height/2 - EDGraphTickLength)];
        [path lineToPoint:NSMakePoint(i*distanceIncrement, [self frame].size.height/2 + EDGraphTickLength)];
    }
    [path stroke];
}

- (NSArray *)getLowestIntegralFactors:(int)number{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (int i=1; i<=(number/2); i++){
        // if mod == 0
        if((number % i) == 0){
            [results addObject:[[NSNumber alloc] initWithInt:i]];
        }
    }
    return results;
}
#pragma mark calculations
- (NSMutableDictionary *)calculateGridIncrement:(int)maxValue length:(float)length{
    // start by default with one grid line per unit
    float distanceIncrement = length/maxValue;
    NSArray *factors = [self getLowestIntegralFactors:maxValue];
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    // check if distance falls within bounds
    for (NSNumber *factor in factors){
        distanceIncrement = length/[factor floatValue];
        
        // if grid distance falls within the bounds of the thresholds then return that value
        if ((distanceIncrement < EDGridIncrementalMaximum) && (distanceIncrement > EDGridIncrementalMinimum)){
            // get number of grid lines
            //numGridLines = maxValue/[factor intValue];
            [results setObject:[[NSNumber alloc] initWithInt:[factor intValue]] forKey:EDKeyGridLinesCount];
            [results setObject:[[NSNumber alloc] initWithFloat:distanceIncrement] forKey:EDKeyDistanceIncrement];
            [results setObject:[[NSNumber alloc] initWithInt:(maxValue/[factor floatValue])] forKey:EDKeyGridFactor];
            return results;
        }
    }
    // by default return grid the size of the maximum value
    [results setObject:[[NSNumber alloc] initWithInt:maxValue] forKey:EDKeyGridLinesCount];
    [results setObject:[[NSNumber alloc] initWithFloat:(length/maxValue)] forKey:EDKeyDistanceIncrement];
    [results setObject:[[NSNumber alloc] initWithInt:1] forKey:EDKeyGridFactor];
    
    return results;
}

- (NSMutableDictionary *)calculateGraphOrigin{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    int absDistanceHoriz = abs([[(EDGraph *)[self dataObj] minValueX] intValue]) + abs([[(EDGraph *)[self dataObj] maxValueX] intValue]);
    int absDistanceVertical = abs([[(EDGraph *)[self dataObj] minValueY] intValue]) + abs([[(EDGraph *)[self dataObj] maxValueY] intValue]);
    float ratioHoriz = ([[(EDGraph *)[self dataObj] minValueX] floatValue] + [[(EDGraph *)[self dataObj] maxValueX] floatValue])/absDistanceHoriz;
    float ratioVertical = ([[(EDGraph *)[self dataObj] minValueY] floatValue]+ [[(EDGraph *)[self dataObj] maxValueY] floatValue])/absDistanceVertical;
    NSLog(@"horiz ratio:%f vertical ratio:%f", ratioHoriz, ratioVertical);
    return results;
}

#pragma mark labels
- (void)drawLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal{
    NSTextField *numberField, *labelField;
    // grid lines multiplied by 2 because the calculation only covers half the axis
    int numGridLinesVertical = [[gridInfoVertical objectForKey:EDKeyGridLinesCount] intValue];
    int numGridLinesHorizontal = [[gridInfoHorizontal objectForKey:EDKeyGridLinesCount] intValue];
    float distanceIncrementVertical = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float distanceIncrementHorizontal = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
 
    // draw y label
    labelField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    [labelField setStringValue:[[NSString alloc] initWithFormat:@"y"]];
    [labelField setBezeled:FALSE];
    [labelField setDrawsBackground:FALSE];
    [labelField setEditable:FALSE];
    [labelField setSelectable:FALSE];
    [labelField setFrameOrigin:NSMakePoint([self frame].size.width/2 + EDGraphVerticalLabelHorizontalOffset, 0 + EDGraphYLabelVerticalOffset)];
    [self addSubview:labelField];
    [_labels addObject:labelField];
    
    // draw x label
    labelField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    [labelField setStringValue:[[NSString alloc] initWithFormat:@"x"]];
    [labelField setBezeled:FALSE];
    [labelField setDrawsBackground:FALSE];
    [labelField setEditable:FALSE];
    [labelField setSelectable:FALSE];
    [labelField setFrameOrigin:NSMakePoint([self frame].size.width + EDGraphHorizontalLabelHorizontalOffset + EDGraphXLabelHorizontalOffset, [self frame].size.height/2 + EDGraphHorizontalLabelVerticalOffset)];
    [self addSubview:labelField];
    [_labels addObject:labelField];
    
    // draw positive x labels
    for (int i=1; i<numGridLinesHorizontal; i++) {
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"%d", i * [[gridInfoHorizontal objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
    
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint([self frame].size.width/2 + (distanceIncrementHorizontal * i + EDGraphHorizontalLabelHorizontalOffset), [self frame].size.height/2 + EDGraphHorizontalLabelVerticalOffset)];
        
        // add to list
        [_labels addObject:numberField];
    }
    
    // draw negative x labels
    for (int i=1; i<numGridLinesHorizontal; i++) {
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"-%d", i * [[gridInfoHorizontal objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
    
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint([self frame].size.width/2 - (distanceIncrementHorizontal * i - EDGraphHorizontalLabelHorizontalOffset + EDGraphHorizontalLabelHorizontalNegativeOffset), [self frame].size.height/2 + EDGraphHorizontalLabelVerticalOffset)];
        
        // add to list
        [_labels addObject:numberField];
    }
    
    // draw positive y labels
    for (int i=1; i<numGridLinesVertical; i++) {
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"%d", i * [[gridInfoVertical objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
    
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint([self frame].size.width/2 + EDGraphVerticalLabelHorizontalOffset, [self frame].size.height/2 - (distanceIncrementVertical * i + EDGraphVerticalLabelVerticalOffset))];
        
        // add to list
        [_labels addObject:numberField];
    }
    
    // draw negative y labels
    for (int i=1; i<numGridLinesVertical; i++) {
        numberField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [numberField setStringValue:[[NSString alloc] initWithFormat:@"-%d", i * [[gridInfoVertical objectForKey:EDKeyGridFactor] intValue]]];
        [numberField setBezeled:FALSE];
        [numberField setDrawsBackground:FALSE];
        [numberField setEditable:FALSE];
        [numberField setSelectable:FALSE];
    
        [self addSubview:numberField];
        
        // position it
        [numberField setFrameOrigin:NSMakePoint([self frame].size.width/2 + EDGraphVerticalLabelHorizontalOffset, [self frame].size.height/2 + (distanceIncrementVertical * i - EDGraphVerticalLabelVerticalOffset))];
        
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

- (void)drawPoints:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal{
    float distanceIncrementVertical = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float distanceIncrementHorizontal = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    float originX, originY;
    
    // set origin points
    originX = [self frame].size.width/2;
    originY = [self frame].size.height/2;
    
    // set point color
    [[NSColor blackColor] setFill];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    for (EDPoint *point in [(EDGraph *)[self dataObj] points]) {
        if ([point isVisible]) {
            // draw point
            path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect([self frame].size.width/2 + ([point locationX]/[[gridInfoHorizontal objectForKey:EDKeyGridFactor] floatValue]) * distanceIncrementHorizontal - EDGraphPointDiameter/2,[self frame].size.height/2 - ([point locationY]/[[gridInfoVertical objectForKey:EDKeyGridFactor] floatValue]) * distanceIncrementVertical - EDGraphPointDiameter/2, EDGraphPointDiameter, EDGraphPointDiameter)];
            [path fill]; 
        }
    }
    //[self setNeedsDisplayInRect:[self frame]];
}

- (void)drawPointLabels:(NSDictionary *)gridInfoVertical horizontal:(NSDictionary *)gridInfoHorizontal{
    NSTextField *pointLabel;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    float distanceIncrementVertical = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float distanceIncrementHorizontal = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    float horizontalOffset, labelHeight, labelWidth, originX, originY, pointLocX, pointLocY;
    
    // set origin points
    originX = [self frame].size.width/2;
    originY = [self frame].size.height/2;
    
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
                
                // reset width and height based off calculations
                //[pointLabel setFrameSize:NSMakeSize(EDGraphPointLabelWidth, labelHeight)];
                
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