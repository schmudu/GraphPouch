//
//  EDPageViewContainer.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/19/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPageViewContainer.h"
#import "EDPage.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"
#import "EDCoreDataUtility+Graphs.h"
#import "EDGraphView.h"
#import "EDGraph.h"

@interface EDPageViewContainer()
- (NSMutableDictionary *)calculateGraphOrigin:(EDGraph *)graph height:(float)graphHeight width:(float)graphWidth;
- (void)onContextChanged:(NSNotification *)note;
- (NSMutableDictionary *)calculateGridIncrement:(float)maxValue minValue:(float)minValue originRatio:(float)ratio length:(float)length scale:(int)scale;
- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo width:(float)graphWidth height:(float)graphHeight graph:(EDGraph *)graph;
@end

@implementation EDPageViewContainer

- (id)initWithFrame:(NSRect)frame page:(EDPage *)page
{
    self = [super initWithFrame:frame];
    if (self) {
        _page = page;
        _context = [page managedObjectContext];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

#pragma mark drawing
- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [self drawGraphs];
}

- (void)drawGraphs{
    NSArray *graphs = [EDCoreDataUtility getGraphsForPage:_page context:_context];
    float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
    float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
    float graphWidth, graphHeight;
    NSBezierPath *path;
    NSDictionary *horizontalResults, *verticalResults;
    NSDictionary *originInfo;
    [[NSColor colorWithHexColorString:EDGraphBorderColor] setStroke];
    
    // for each of the graphs draw them
    for (EDGraph *graph in graphs){
        // draw graph in that position
        graphWidth = xRatio * ([graph elementWidth] - [EDGraphView graphMargin] * 2);
        graphHeight = yRatio * ([graph elementHeight] - [EDGraphView graphMargin] * 2);
        originInfo = [self calculateGraphOrigin:graph height:graphHeight width:graphWidth];
        horizontalResults = [self calculateGridIncrement:[[graph maxValueX] floatValue] minValue:[[graph minValueX] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioHorizontal] floatValue] length:graphWidth scale:[[graph scaleX] intValue]];
        horizontalResults = [self calculateGridIncrement:[[graph maxValueY] floatValue] minValue:[[graph minValueY] floatValue] originRatio:[[originInfo valueForKey:EDKeyRatioVertical] floatValue] length:graphHeight scale:[[graph scaleY] intValue]];
        
        // draw border
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(xRatio * ([EDGraphView graphMargin] + [graph locationX]),
                                                           yRatio * ([graph locationY] + [EDGraphView graphMargin]),
                                                           graphWidth,
                                                           graphHeight)];
        [path setLineWidth:EDPageViewGraphBorderLineWidth];
        [path stroke];
        
        // draw grid
        [self drawVerticalGrid:verticalResults horizontalGrid:horizontalResults origin:originInfo width:graphWidth height:graphHeight graph:graph];
    }
}

- (void)onContextChanged:(NSNotification *)note{
    // update if needed
    NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    NSArray *insertedArray = [[[note userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    NSArray *removedArray = [[[note userInfo] objectForKey:NSDeletedObjectsKey] allObjects];
    NSMutableArray *allObjects = [NSMutableArray arrayWithArray:updatedArray];
    [allObjects addObjectsFromArray:insertedArray];
    [allObjects addObjectsFromArray:removedArray];
    
    // if any object was updated, removed or inserted on this page then this page needs to be updated
    for (NSManagedObject *object in allObjects){
        if ((object == _page) || ([_page containsObject:object])){
            [self setNeedsDisplay:TRUE];
        }
    }
}

#pragma mark draw graphs
- (NSMutableDictionary *)calculateGraphOrigin:(EDGraph *)graph height:(float)graphHeight width:(float)graphWidth{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    int absDistanceHoriz = abs([[graph minValueX] intValue]) + abs([[graph maxValueX] intValue]);
    int absDistanceVertical = abs([[graph minValueX]intValue]) + abs([[graph maxValueY] intValue]);
    float ratioHoriz = ([[graph minValueX] floatValue] + [[graph maxValueX] floatValue])/absDistanceHoriz;
    float ratioVertical = ([[graph minValueY] floatValue]+ [[graph maxValueY] floatValue])/absDistanceVertical;
    float originVerticalPosition = graphHeight/2 + (ratioVertical * graphHeight/2) + [EDGraphView graphMargin];
    float originHorizontalPosition = graphWidth/2 - (ratioHoriz * graphWidth/2) + [EDGraphView graphMargin];
    
    [results setValue:[NSNumber numberWithFloat:ratioHoriz] forKey:EDKeyRatioHorizontal];
    [results setValue:[NSNumber numberWithFloat:ratioVertical] forKey:EDKeyRatioVertical];
    [results setValue:[NSNumber numberWithFloat:originHorizontalPosition] forKey:EDKeyOriginPositionHorizontal];
    [results setValue:[NSNumber numberWithFloat:originVerticalPosition] forKey:EDKeyOriginPositionVertical];
    return results;
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

- (void)drawVerticalGrid:(NSDictionary *)gridInfoVertical horizontalGrid:(NSDictionary *)gridInfoHorizontal origin:(NSDictionary *)originInfo width:(float)graphWidth height:(float)graphHeight graph:(EDGraph *)graph{
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSBezierPath *outlinePath = [NSBezierPath bezierPath];
    int numGridLines = [[gridInfoVertical objectForKey:EDKeyNumberGridLinesPositive] intValue];
    float distanceIncrement = [[gridInfoVertical objectForKey:EDKeyDistanceIncrement] floatValue];
    float originPosVertical = [[originInfo valueForKey:EDKeyOriginPositionVertical] floatValue];
    float originPosHorizontal = [[originInfo valueForKey:EDKeyOriginPositionHorizontal] floatValue];
    float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
    float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
    
    [[NSColor redColor] setStroke];
    
    /*
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(xRatio * ([EDGraphView graphMargin] + [graph locationX]),
                                                           yRatio * ([graph locationY] + [EDGraphView graphMargin]),
                                                           graphWidth,
                                                           graphHeight)];
     */
    
    // draw top/bottom of grid
#warning the next four lines work
    [outlinePath moveToPoint:NSMakePoint(xRatio * ([EDGraphView graphMargin]+[graph locationX]), ([EDGraphView graphMargin]+[graph locationY]) * yRatio)];
    [outlinePath lineToPoint:NSMakePoint(xRatio * ([EDGraphView graphMargin]+[graph locationX]) + graphWidth, ([EDGraphView graphMargin]+[graph locationY]) * yRatio)];
    [outlinePath moveToPoint:NSMakePoint(xRatio * ([EDGraphView graphMargin]+[graph locationX]), ([EDGraphView graphMargin]+[graph locationY]) * yRatio + graphHeight)];
    [outlinePath lineToPoint:NSMakePoint(xRatio * ([EDGraphView graphMargin]+[graph locationX]) + graphWidth, ([EDGraphView graphMargin]+[graph locationY]) * yRatio + graphHeight)];
    
    // draw right/left side of grid
    [outlinePath moveToPoint:NSMakePoint([EDGraphView graphMargin], [EDGraphView graphMargin])];
    [outlinePath lineToPoint:NSMakePoint([EDGraphView graphMargin], [EDGraphView graphMargin] + graphHeight)];
    [outlinePath moveToPoint:NSMakePoint([EDGraphView graphMargin] + graphWidth, [EDGraphView graphMargin])];
    [outlinePath lineToPoint:NSMakePoint([EDGraphView graphMargin] + graphWidth, [EDGraphView graphMargin] + graphHeight)];
    
    [outlinePath stroke];
    
    /*
    // set stroke
    [[NSColor colorWithHexColorString:EDGridColor alpha:EDGridAlpha] setStroke];
    
    // draw positive horizontal lines starting from origin
    for (int i=0; i<=numGridLines; i++) {
        if ([[graph minValueX] intValue] == 0){
            [path moveToPoint:NSMakePoint([EDGraphView graphMargin], originPosVertical - i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([EDGraphView graphMargin] + graphWidth, originPosVertical - i*distanceIncrement)];
        }
        else if ([[graph maxValueX] intValue] == 0){
            [path moveToPoint:NSMakePoint([EDGraphView graphMargin], originPosVertical - i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([EDGraphView graphMargin] + graphWidth, originPosVertical - i*distanceIncrement)];
        }
        else{
            [path moveToPoint:NSMakePoint([EDGraphView graphMargin], originPosVertical - i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([EDGraphView graphMargin] + graphWidth, originPosVertical - i*distanceIncrement)];
        }
    }
    
     // draw negative horizontal lines starting from origin
    numGridLines = abs([[gridInfoVertical objectForKey:EDKeyNumberGridLinesNegative] intValue]);
    for (int i=0; i<=numGridLines; i++) {
        if ([[graph minValueX] intValue] == 0){
            [path moveToPoint:NSMakePoint([EDGraphView graphMargin], originPosVertical + i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([EDGraphView graphMargin] + graphWidth, originPosVertical + i*distanceIncrement)];
        }
        else if ([[graph maxValueX] intValue] == 0){
            [path moveToPoint:NSMakePoint([EDGraphView graphMargin], originPosVertical + i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([EDGraphView graphMargin] + graphWidth, originPosVertical + i*distanceIncrement)];
        }
        else{
            [path moveToPoint:NSMakePoint([EDGraphView graphMargin], originPosVertical + i*distanceIncrement)];
            [path lineToPoint:NSMakePoint([EDGraphView graphMargin] + graphWidth, originPosVertical + i*distanceIncrement)];
        }
    }
    
     // grid lines multiplied by 2 because the calculation only covers half the axis
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesPositive] intValue];
    distanceIncrement = [[gridInfoHorizontal objectForKey:EDKeyDistanceIncrement] floatValue];
    
    // draw positive vertical lines
    //NSLog(@"frame height:%f graph view height:%f graph height:%f margin:%f graphMargin:%f", [self frame].size.height, [self height], graphHeight, [EDGraphView margin], [EDGraphView graphMargin]);
    for (int i=0; i<=numGridLines; i++) {
        if ([[graph minValueY] intValue] == 0){
            [path moveToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [EDGraphView graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, graphHeight + [EDGraphView graphMargin])];
        }
        else if ([[graph maxValueY] intValue] == 0){
            [path moveToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [EDGraphView graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, graphHeight + [EDGraphView graphMargin])];
        }
        else{
            [path moveToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, [EDGraphView graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal + i*distanceIncrement, graphHeight + [EDGraphView graphMargin])];
        }
    }
    
    numGridLines = [[gridInfoHorizontal objectForKey:EDKeyNumberGridLinesNegative] intValue];
    // draw negative vertical lines
    for (int i=0; i<=numGridLines; i++) {
        if ([[graph minValueY] intValue] == 0){
            [path moveToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [EDGraphView graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, graphHeight + [EDGraphView graphMargin])];
        }
        else if ([[graph maxValueY] intValue] == 0){
            [path moveToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [EDGraphView graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, graphHeight + [EDGraphView graphMargin])];
        }
        else{
            [path moveToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, [EDGraphView graphMargin])];
            [path lineToPoint:NSMakePoint(originPosHorizontal - i*distanceIncrement, graphHeight + [EDGraphView graphMargin])];
        }
    }
    
    [path stroke];
     */
}
@end
