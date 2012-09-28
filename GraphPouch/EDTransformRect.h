//
//  EDTransformRect.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDTransformCornerPoint.h"
#import "EDElement.h"

@interface EDTransformRect : NSView{
    EDElement *_element;
    NSNotificationCenter *_nc;
    EDTransformCornerPoint *topLeftPoint, *topRightPoint, *bottomLeftPoint, *bottomRightPoint;
}
- (id)initWithFrame:(NSRect)frame element:(EDElement *)element;
- (void)setDimensionAndPositionElementViewOrigin:(NSPoint)origin element:(EDElement *)element;
@end
