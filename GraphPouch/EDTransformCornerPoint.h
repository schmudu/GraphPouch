//
//  EDTransformCornerPoint.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDTransformPoint.h"

@interface EDTransformCornerPoint : EDTransformPoint{
    EDTransformCornerPoint *verticalPoint, *horizontalPoint;
}

- (id)initWithFrame:(NSRect)frame verticalPoint:(EDTransformCornerPoint *)newVerticalPoint horizPoint:(EDTransformCornerPoint *)newHorizPoint;
- (void)onVerticalPointMoved:(NSNotification *)note;
- (void)onHorizontalPointMoved:(NSNotification *)note;

@end
