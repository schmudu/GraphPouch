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
    NSPoint inequalityPoint;
    BOOL firstPointDrawnForEquation = true;
    NSError *error;
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSBezierPath *inequalityPath = [NSBezierPath bezierPath];
    float diffX, marginDiff, ratioHorizontal, ratioVertical, valueX, valueY, positionVertical;
    
    // set origin points
    float originVerticalPosition = [[_infoOrigin valueForKey:EDKeyOriginPositionVertical] floatValue] - [EDGraphView graphMargin];
    float originHorizontalPosition = [[_infoOrigin valueForKey:EDKeyOriginPositionHorizontal] floatValue] - [EDGraphView graphMargin];
    
    // ratio positive/negative vertical
    float ratioYPositive, ratioYNegative;
    ratioYPositive = [[_graph maxValueY] floatValue]/([[_graph maxValueY] floatValue] + fabsf([[_graph minValueY] floatValue]));
    ratioYNegative = 1 - ratioYPositive;
    
    // max/min graph positions
    float graphVerticalPositionMin, graphVerticalPositionMax;
    
    // set stroke
    [[NSColor blackColor] setStroke];
    [path setLineWidth:EDEquationLineWidth];
    
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
     
        // if y is greater than max or less than min * threshold modifier than break from loop
        // e.g. if max is 10 and modifier is 1.5, then points greater than 15 will not be drawn
        if([[_equation equationType] intValue] == EDEquationTypeEqual){
            if ((isnan(valueY)) || (valueY > [[_graph maxValueY] floatValue] * EDEquationMaxThresholdDrawingValue) || (valueY < [[_graph minValueY] floatValue]*EDEquationMaxThresholdDrawingValue)){
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
        else{
            // equation is inequality
            if ((isnan(valueY)) || (valueY > [[_graph maxValueY] floatValue] * EDEquationMaxThresholdDrawingValue) || (valueY < [[_graph minValueY] floatValue]*EDEquationMaxThresholdDrawingValue)){
                
                // draw fill in if the user has chosen an inequality
                if ((valueY > [[_graph maxValueY] floatValue] * EDEquationMaxThresholdDrawingValue) && ((([[_equation equationType] intValue] == EDEquationTypeLessThan)) || ([[_equation equationType] intValue] == EDEquationTypeLessThanOrEqual))){
                    graphVerticalPositionMax = originVerticalPosition - ([self frame].size.height);
                    graphVerticalPositionMin = originVerticalPosition + ([self frame].size.height);
                    [inequalityPath moveToPoint:NSMakePoint(i, graphVerticalPositionMax)];
                    [inequalityPath lineToPoint:NSMakePoint(i, graphVerticalPositionMin)];
                    
                }
                else if ((valueY < [[_graph minValueY] floatValue] * EDEquationMaxThresholdDrawingValue) && ((([[_equation equationType] intValue] == EDEquationTypeGreaterThan)) || ([[_equation equationType] intValue] == EDEquationTypeGreaterThanOrEqual))){
                    graphVerticalPositionMax = originVerticalPosition - ([self frame].size.height);
                    graphVerticalPositionMin = originVerticalPosition + ([self frame].size.height);
                    [inequalityPath moveToPoint:NSMakePoint(i, graphVerticalPositionMin)];
                    [inequalityPath lineToPoint:NSMakePoint(i, graphVerticalPositionMax)];
                    
                }
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
                inequalityPoint = NSMakePoint(i, positionVertical);
                [inequalityPath moveToPoint:NSMakePoint(i, positionVertical)];
                [path moveToPoint:NSMakePoint(i, positionVertical)];
                //NSLog(@"moving line to point: x:%f y:%f pos x:%f pos y:%f eq:%@", valueX, valueY, i, positionVertical, [_equation equation]);
                firstPointDrawnForEquation = false;
            }
            else if (error){
                // reset
                error = nil;
                
                // set variable so that equation will not draw to next point
                firstPointDrawnForEquation = true;
            }
            else {
                // if includes equal
                if(([[_equation equationType] intValue] == EDEquationTypeGreaterThanOrEqual) || ([[_equation equationType] intValue] == EDEquationTypeLessThanOrEqual)){
                    [path lineToPoint:NSMakePoint(i, positionVertical)];
                    //NSLog(@"inequality inclusive drawing line to point: x:%f y:%f pos x:%f pos y:%f eq:%@", valueX, valueY, i, positionVertical, [_equation equation]);
                }
                else{
                    // if distance is greater than dashed line then calculate new point
                    if(sqrtf(powf(i-inequalityPoint.x,2)+powf(positionVertical-inequalityPoint.y,2))>10)
                        inequalityPoint = NSMakePoint(i, positionVertical);
                        
                    // dashed line for not equal
                    if(fmodf(sqrtf(powf(i-inequalityPoint.x,2)+powf(positionVertical-inequalityPoint.y,2)), 10)<5)
                        [path lineToPoint:NSMakePoint(i, positionVertical)];
                    else
                        [path moveToPoint:NSMakePoint(i, positionVertical)];
                }
                
                // inequality fill
                [inequalityPath moveToPoint:NSMakePoint(i, positionVertical)];
                
                // depending on greater than or less than stroke to bottom of graph
                if(([[_equation equationType] intValue] == EDEquationTypeGreaterThan) || ([[_equation equationType] intValue] == EDEquationTypeGreaterThanOrEqual)){
                    graphVerticalPositionMax = originVerticalPosition - ([self frame].size.height);
                    [inequalityPath lineToPoint:NSMakePoint(i, graphVerticalPositionMax)];
                }
                else{
                    graphVerticalPositionMin = originVerticalPosition + ([self frame].size.height);
                    [inequalityPath lineToPoint:NSMakePoint(i, graphVerticalPositionMin)];
                }
            }
        }
    }
    
    [path stroke];
    
    // if inequality need to fill path
    if(([[_equation equationType] intValue] == EDEquationTypeGreaterThan) ||
       ([[_equation equationType] intValue] == EDEquationTypeGreaterThanOrEqual) ||
       ([[_equation equationType] intValue] == EDEquationTypeLessThan) ||
       ([[_equation equationType] intValue] == EDEquationTypeLessThanOrEqual)){
        NSColor *fillColor;
        if ([[(NSColor *)[_equation inequalityColor] colorSpaceName] isEqualToString:@"NSCalibratedWhiteColorSpace"])
            fillColor = [NSColor colorWithCalibratedWhite:[(NSColor *)[_equation inequalityColor] whiteComponent] alpha:[_equation inequalityAlpha]];
        else
            fillColor = [NSColor colorWithCalibratedRed:[(NSColor *)[_equation inequalityColor] redComponent] green:[(NSColor *)[_equation inequalityColor] greenComponent] blue:[(NSColor *)[_equation inequalityColor] blueComponent] alpha:[_equation inequalityAlpha]];
        [fillColor setStroke];
        [inequalityPath stroke];
    }
}

@end
