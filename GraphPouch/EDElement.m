//
//  EDElement.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDElement.h"


@implementation EDElement

@dynamic zIndex;
@dynamic selected;
@dynamic locationX;
@dynamic locationY;
@dynamic elementWidth;
@dynamic elementHeight;

- (void)copyAttributes:(EDElement *)source{
    [self setZIndex:[source zIndex]];
    [self setSelected:[source selected]];
    [self setLocationX:[source locationX]];
    [self setLocationY:[source locationY]];
    [self setElementWidth:[source elementWidth]];
    [self setElementHeight:[source elementHeight]];
}
@end
