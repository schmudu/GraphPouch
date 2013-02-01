//
//  EDTransformCornerPointOnlyHorizontal.h
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDTransformPointOnlyHorizontal.h"

@interface EDTransformCornerPointOnlyHorizontal : EDTransformPointOnlyHorizontal{
    EDTransformCornerPointOnlyHorizontal *verticalPoint, *horizontalPoint;
}

- (id)initWithFrame:(NSRect)frame verticalPoint:(EDTransformCornerPointOnlyHorizontal *)newVerticalPoint horizPoint:(EDTransformCornerPointOnlyHorizontal *)newHorizPoint;
- (void)onVerticalPointMoved:(NSNotification *)note;
- (void)onHorizontalPointMoved:(NSNotification *)note;
@end
