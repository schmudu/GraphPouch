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

@interface EDTransformRect()
-(void)onTransformPointDragged:(NSNotification *)note;
@end

@implementation EDTransformRect

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        topLeftPoint = [EDTransformCornerPoint alloc];
        topRightPoint = [EDTransformCornerPoint alloc];
        bottomLeftPoint = [EDTransformCornerPoint alloc];
        bottomRightPoint = [EDTransformCornerPoint alloc];
        
        [topLeftPoint initWithFrame:NSMakeRect(0, 0, EDTransformPointLength, EDTransformPointLength) 
                      verticalPoint:(EDTransformCornerPoint *)topRightPoint 
                         horizPoint:(EDTransformCornerPoint *)bottomLeftPoint];
        [topRightPoint initWithFrame:NSMakeRect([self frame].size.width - EDTransformPointLength, 0, EDTransformPointLength, EDTransformPointLength)
                       verticalPoint:(EDTransformCornerPoint *)topLeftPoint 
                          horizPoint:(EDTransformCornerPoint *)bottomRightPoint];
        [bottomLeftPoint initWithFrame:NSMakeRect(0, [self frame].size.height - EDTransformPointLength, EDTransformPointLength, EDTransformPointLength)
                         verticalPoint:(EDTransformCornerPoint *)bottomRightPoint 
                            horizPoint:(EDTransformCornerPoint *)topLeftPoint];
        [bottomRightPoint initWithFrame:NSMakeRect([self frame].size.width - EDTransformPointLength, [self frame].size.height - EDTransformPointLength, EDTransformPointLength, EDTransformPointLength)
                          verticalPoint:(EDTransformCornerPoint *)bottomLeftPoint 
                             horizPoint:(EDTransformCornerPoint *)topRightPoint];
        
        // listen
        _nc = [NSNotificationCenter defaultCenter];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:topLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:topRightPoint];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:bottomLeftPoint];
        [_nc addObserver:self selector:@selector(onTransformPointDragged:) name:EDEventTransformPointDragged object:bottomRightPoint];
    }
    
    return self;
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
    [results setValue:[[NSNumber alloc] initWithFloat:(maxX-minX)] forKey:EDKeyWidth];
    [results setValue:[[NSNumber alloc] initWithFloat:(maxY-minY)] forKey:EDKeyHeight];
    
    //dispatch
    [_nc postNotificationName:EDEventTransformRectChanged object:self userInfo:results];
}
@end
