//
//  EDGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDGraphView.h"
#import "EDElement.h"
#import "NSManagedObject+Attributes.h"
#import "NSObject+Document.h"
#import "EDGraph.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"

@interface EDGraphView()
- (NSArray *)getLowestIntegralFactors:(int)number;
- (NSMutableDictionary *)calculateGridIncrement:(int)maxValue length:(float)length;
- (void)drawCoordinateAxes;
- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal;
@end

@implementation EDGraphView
//@synthesize graph;

- (BOOL)isFlipped{
    return TRUE;
}

- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph{
    self = [super initWithFrame:frame];
    if (self){
        //generate id
        [self setViewID:[EDGraphView generateID]];
        
        // set model info
        [self setDataObj:myGraph];
    }
    return self;
}

- (void) dealloc{
    NSManagedObjectContext *context = [self currentContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    // stroke grid
    if ([(EDGraph *)[self dataObj] hasGridLines]) {
        NSDictionary *verticalResults = [self calculateGridIncrement:EDGridMaximum length:[self frame].size.height/2];
        NSDictionary *horizontalResults = [self calculateGridIncrement:EDGridMaximum length:[self frame].size.width/2];
        [self drawVerticalGrid:verticalResults horizontalGrid:horizontalResults];
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
    
}

- (void)drawCoordinateAxes{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float height = [self frame].size.height;
    float width = [self frame].size.width;
    [[NSColor blackColor] setStroke];
    
    //draw x-axis
    [path moveToPoint:NSMakePoint(0, height/2)];
    [path lineToPoint:NSMakePoint(width, height/2)];
    
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
    
    [path setLineWidth:EDGraphDefaultCoordinateLineWidth];
    [path stroke];
}

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
@end