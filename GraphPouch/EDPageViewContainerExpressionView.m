//
//  EDPageViewContainerExpressionView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/20/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDPageViewContainerExpressionView.h"
#import "EDExpressionView.h"

@interface EDPageViewContainerExpressionView()
- (void)drawExpression;
@end

@implementation EDPageViewContainerExpressionView

- (id)initWithFrame:(NSRect)frame expression:(EDExpression *)expression context:(NSManagedObjectContext *)context
{
    self = [super initWithFrame:frame];
    if (self) {
        _expression = expression;
        _context = context;
        
        float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
        float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
        
        EDExpressionView *expressionView = [[EDExpressionView alloc] initWithFrame:NSMakeRect(0, 0, [_expression elementWidth], [_expression elementHeight]) expression:_expression];
        
        // scale image to page view container
        NSRect thumbnailRect = NSMakeRect(0, 0, [_expression elementWidth] * xRatio, [_expression elementHeight] * yRatio);
        NSImage *expressionImage = [[NSImage alloc] initWithData:[expressionView dataWithPDFInsideRect:[expressionView frame]]];
        NSImageView *imageViewExpression = [[NSImageView alloc] initWithFrame:thumbnailRect];
        [imageViewExpression setImageScaling:NSScaleProportionally];
        [imageViewExpression setImage:expressionImage];
        
        // add expression view to stage
        [self addSubview:imageViewExpression];
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawExpression];
}

- (void)drawExpression{
}

@end
