//
//  EDExpressionViewPrint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/20/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDExpressionViewPrint.h"

@implementation EDExpressionViewPrint

- (id)initWithFrame:(NSRect)frameRect expression:(EDExpression *)expression
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // set model info
        [self setDataObj:expression];
        _context = [expression managedObjectContext];
        
        // display expression
        [self validateAndDisplayExpression];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
