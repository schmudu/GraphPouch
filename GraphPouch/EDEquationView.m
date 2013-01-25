//
//  EDEquationView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/2/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDEquationView.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"
#import "EDParser.h"
#import "EDGraphView.h"

@interface EDEquationView()
@end

@implementation EDEquationView

- (id)initWithFrame:(NSRect)frame equation:(EDEquation *)equation
{
    self = [super initWithFrame:frame];
    if (self) {
        _equation = equation;
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)setGraphOrigin:(NSDictionary *)originInfo verticalInfo:(NSDictionary *)verticalInfo horizontalInfo:(NSDictionary *)horizontalInfo graph:(EDGraph *)graph context:(NSManagedObjectContext *)context{
    _infoOrigin = originInfo;
    _infoVertical = verticalInfo;
    _infoHorizontal = horizontalInfo;
    _graph = graph;
    _context = context;
}

- (void)drawRect:(NSRect)dirtyRect
{
    BOOL firstPointDrawnForEquation = true;
    NSError *error;
    NSBezierPath *path = [NSBezierPath bezierPath];
    float diffX, marginDiff, ratioHorizontal, ratioVertical, valueX, valueY, positionVertical;
    
    // set origin points
    float originVerticalPosition = [[_infoOrigin valueForKey:EDKeyOriginPositionVertical] floatValue] - [EDGraphView graphMargin];
    float originHorizontalPosition = [[_infoOrigin valueForKey:EDKeyOriginPositionHorizontal] floatValue] - [EDGraphView graphMargin];
    
    // ratio positive/negative vertical
    float ratioYPositive, ratioYNegative;
    ratioYPositive = [[_graph maxValueY] floatValue]/([[_graph maxValueY] floatValue] + fabsf([[_graph minValueY] floatValue]));
    ratioYNegative = 1 - ratioYPositive;
    
    // set stroke
    [[NSColor redColor] setStroke];
    
    int endInt = (int)[self frame].size.width * EDGraphDependentVariableIncrement;
    float i;
    
    for (int j=0; j<endInt; j++){
        i = j/EDGraphDependentVariableIncrement;
        diffX = i - originHorizontalPosition;
        
        // based on position find x
        if (diffX < 0){
            // x is negative
            ratioHorizontal = -1 * diffX/originHorizontalPosition;
            valueX = ratioHorizontal * [[_graph minValueX] floatValue];
        }
        else if (diffX == 0){
            valueX = 0;
        }
        else{
            // x is positive
            marginDiff = [self frame].size.width - originHorizontalPosition;
            ratioHorizontal = diffX/marginDiff;
            valueX = ratioHorizontal * [[_graph maxValueX] floatValue];
        }
        valueY = [EDParser calculate:[[_equation tokens] array] error:&error context:_context varValue:valueX];
     
        // if y is greater than max or less than min than break from loop
        if ((isnan(valueY)) || (valueY > [[_graph maxValueY] floatValue]) || (valueY < [[_graph minValueY] floatValue]))
            continue;
     
        // based on value find y position
        if (error){
            // we received an error an cannot calculate this value
            // do nothing
        }
        if (valueY < 0){
            // y is negative
            ratioVertical = valueY/[[_graph minValueY] floatValue];
            positionVertical = originVerticalPosition + ratioVertical * ([self frame].size.height * ratioYNegative);
        }
        else if (valueY == 0){
            positionVertical = originVerticalPosition;
        }
        else{
            // y is positive
            ratioVertical = valueY/[[_graph maxValueY] floatValue];
            positionVertical = originVerticalPosition - ratioVertical * ([self frame].size.height * ratioYPositive);
        }
        
        if (firstPointDrawnForEquation) {
            [path moveToPoint:NSMakePoint(i, positionVertical)];
            firstPointDrawnForEquation = false;
        }
        else if (error){
            // reset
            error = nil;
            
            // set variable so that equation will not draw to next point
            firstPointDrawnForEquation = true;
        }
        else {
            [path lineToPoint:NSMakePoint(i, positionVertical)];
        }
    }
    [path stroke];
}

@end
