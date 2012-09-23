//
//  EDTransformRect.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDTransformCornerPoint.h"

@interface EDTransformRect : NSView{
    EDTransformCornerPoint *topLeftPoint, *topRightPoint, *bottomLeftPoint, *bottomRightPoint;
}
@end
