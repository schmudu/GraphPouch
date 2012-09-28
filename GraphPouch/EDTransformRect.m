//
//  EDTransformRect.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDTransformRect.h"
#import "EDConstants.h"
#import "EDTransformCornerPoint.h"
#import "EDElement.h"

@interface EDTransformRect()
-(void)onTransformPointDragged:(NSNotification *)note;
-(void)onTransformPointMouseUp:(NSNotification *)note;
- (NSMutableDictionary *)getDimensionsOfEvent:(NSNotification *)note;
@end

@implementation EDTransformRect

- (id)initWithFrame:(NSRect)frame element:(EDElement *)element
{
    self = [super initWithFrame:frame];
    if (self) {
        topLeftPoint = [EDTransformCornerPoint alloc];
        topRightPoint = [EDTransformCornerPoint alloc];
        bottomLeftPoint = [EDTransformCornerPoint alloc];
        bottomRightPoint = [EDTransformCornerPoint alloc];
        
        // align element with data attributes
        [topLeftPoint initWithFrame:NSMakeRect([element locationX], [element locationY], EDTransformPointLength, EDTransformPointLength) 
                      verticalPoint:(EDTransformCornerPoint *)topRightPoint 
                         horizPoint:(EDTransformCornerPoint *)bottomLeftPoint];
        [topRightPoint initWithFrame:NSMakeRect([element locationX] + [element elementWidth] - EDTransformPointLength, [element locationY], EDTransformPointLength, EDTransformPointLength)
                       verticalPoint:(EDTransformCornerPoint *)topLeftPoint 
                          horizPoint:(EDTransformCornerPoint *)bottomRightPoint];
        [bottomLeftPoint initWithFrame:NSMakeRect([element locationX], [element locationY] + [element elementHeight] - EDTransformPointLength, EDTransformPointLength, EDTransformPointLength)
                         verticalPoint:(EDTransformCornerPoint *)bottomRightPoint 
                            horizPoint:(EDTransformCornerPoint *)topLeftPoint];
        [bottomRightPoint initWithFrame:NSMakeRect([element locationX] + [element elementWidth] - EDTransformPointLength, [element locationY] + [element elementHeight] - EDTransformPointLength, EDTransformPointLength, EDTransformPointLength)
                          verticalPoint:(EDTransformCornerPoint *)bottomLeftPoint 
                             horizPoint:(EDTransformCornerPoint *)topRightPoint];
        
        // listen
        _nc = [NSNotificationCenter defaultCenter];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:topLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:topRightPoint];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:bottomLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:bottomRightPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseUp:) name:EDEventTransformMouseUp object:topLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseUp:) name:EDEventTransformMouseUp object:topRightPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseUp:) name:EDEventTransformMouseUp object:bottomLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointMouseUp:) name:EDEventTransformMouseUp object:bottomRightPoint];
    }
    
    return self;
}

- (void)dealloc{
    [_nc removeObserver:self name:EDEventTransformPointDragged object:topLeftPoint];
    [_nc removeObserver:self name:EDEventTransformPointDragged object:topRightPoint];
    [_nc removeObserver:self name:EDEventTransformPointDragged object:bottomLeftPoint];
    [_nc removeObserver:self name:EDEventTransformPointDragged object:bottomRightPoint];
    [_nc removeObserver:self name:EDEventTransformMouseUp object:topLeftPoint];
    [_nc removeObserver:self name:EDEventTransformMouseUp object:topRightPoint];
    [_nc removeObserver:self name:EDEventTransformMouseUp object:bottomLeftPoint];
    [_nc removeObserver:self name:EDEventTransformMouseUp object:bottomRightPoint];
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if(![[self subviews] containsObject:topLeftPoint]){
        [self addSubview:topLeftPoint];
    }
    if(![[self subviews] containsObject:topRightPoint]){
        [self addSubview:topRightPoint];
    }
    if(![[self subviews] containsObject:bottomLeftPoint]){
        [self addSubview:bottomLeftPoint];
    }
    if(![[self subviews] containsObject:bottomRightPoint]){
        [self addSubview:bottomRightPoint];
    }
}

# pragma mark transform point dragged
-(void)onTransformPointDragged:(NSNotification *)note{
    NSMutableDictionary *results = [self getDimensionsOfEvent:note];
    [_nc postNotificationName:EDEventTransformRectChanged object:self userInfo:results];
}

-(void)onTransformPointMouseUp:(NSNotification *)note{
    NSMutableDictionary *results = [self getDimensionsOfEvent:note];
    [_nc postNotificationName:EDEventTransformMouseUp object:self userInfo:results];
}

- (NSMutableDictionary *)getDimensionsOfEvent:(NSNotification *)note{
    float minX, minY, maxX = 0, maxY = 0;
    int i =0;
    EDTransformCornerPoint *currentPoint;
    // figure out which point is where then dispatch event notifying rectangle of the change
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    for (NSView *view in [self subviews]){
        currentPoint = (EDTransformCornerPoint *)view;
        
        if(i == 0){
            minX = [currentPoint frame].origin.x;
            minY = [currentPoint frame].origin.y;
        }
            
        // test for min and max
        if ([currentPoint frame].origin.x < minX) 
            minX = [currentPoint frame].origin.x;
        if ([currentPoint frame].origin.y < minY) 
            minY = [currentPoint frame].origin.y;
        if ([currentPoint frame].origin.x > maxX) 
            maxX = [currentPoint frame].origin.x;
        if ([currentPoint frame].origin.y > maxY) 
            maxY = [currentPoint frame].origin.y;
        
        i++;
    }
 
    // we need to convert the point back window coordinates
    NSPoint windowPoint = [self convertPoint:NSMakePoint(minX, minY) toView:[self superview]];
    
    // set results
    [results setValue:[[NSNumber alloc] initWithFloat:windowPoint.x] forKey:EDKeyLocationX];
    [results setValue:[[NSNumber alloc] initWithFloat:windowPoint.y] forKey:EDKeyLocationY];
    [results setValue:[[NSNumber alloc] initWithFloat:(maxX-minX+EDTransformPointLength)] forKey:EDKeyWidth];
    [results setValue:[[NSNumber alloc] initWithFloat:(maxY-minY+EDTransformPointLength)] forKey:EDKeyHeight];
 
    return results;
}

#pragma element
- (void)setDimensionAndPositionElementViewOrigin:(NSPoint)origin element:(EDElement *)element{
    // set position and dimension based on element
    EDTransformCornerPoint *topLeft, *topRight, *bottomLeft, *bottomRight;
    
    // find the positions of points
    if ([topLeftPoint frame].origin.y < [bottomLeftPoint frame].origin.y){
        if([topLeftPoint frame].origin.x < [topRightPoint frame].origin.x){
            topLeft = topLeftPoint;
            topRight = topRightPoint;
            bottomLeft = bottomLeftPoint;
            bottomRight = bottomRightPoint;
        }
        else {
            topLeft = topRightPoint;
            topRight = topLeftPoint;
            bottomLeft = bottomRightPoint;
            bottomRight = bottomLeftPoint;
        }
    }
    else{
        if([topLeftPoint frame].origin.x < [topRightPoint frame].origin.x){
            topLeft = bottomLeftPoint;
            topRight = bottomRightPoint;
            bottomLeft = topLeftPoint;
            bottomRight = topRightPoint;
        }
        else {
            topLeft = bottomRightPoint;
            topRight = bottomLeftPoint;
            bottomLeft = topRightPoint;
            bottomRight = topLeftPoint;
        }
    }
    
    // set positions
    [topLeftPoint setFrameOrigin:NSMakePoint(origin.x, origin.y)];
    [topRightPoint setFrameOrigin:NSMakePoint(origin.x + [element elementWidth] - EDTransformPointLength, origin.y)];
    [bottomLeftPoint setFrameOrigin:NSMakePoint(origin.x, origin.y + [element elementHeight] - EDTransformPointLength)];
    [bottomRightPoint setFrameOrigin:NSMakePoint(origin.x + [element elementWidth] - EDTransformPointLength, origin.y + [element elementHeight] - EDTransformPointLength)];
    //NSLog(@"right x:%f y:%f", [topRightPoint frame].origin.x, [topRightPoint frame].origin.y);
}
@end
